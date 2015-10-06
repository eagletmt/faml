require 'pathname'
require 'singleton'
require 'hamlit/engine'
require 'hamlit/version'

class IncompatibilitiesGenerator
  include Singleton

  Record = Struct.new(:template, :options, :spec_path, :line_number, :faml_result, :haml_result, :hamlit_result) do
    def incompatible?
      !all_error? && (faml_result != haml_result || faml_result != hamlit_result || haml_result != hamlit_result)
    end

    def grouped_difference
      case
      when faml_result != haml_result && faml_result != hamlit_result && haml_result != hamlit_result
        { 'Faml' => faml_result, 'Haml' => haml_result, 'Hamlit' => hamlit_result }
      when faml_result == haml_result
        { 'Faml, Haml' => faml_result, 'Hamlit' => hamlit_result }
      when faml_result == hamlit_result
        { 'Faml, Hamlit' => faml_result, 'Haml' => haml_result }
      else
        { 'Faml' => faml_result, 'Haml, Hamlit' => haml_result }
      end
    end

    def only_hamlit?
      faml_result == haml_result && faml_result != hamlit_result
    end

    private

    def all_error?
      [faml_result, haml_result, hamlit_result].all? { |r| r.is_a?(Exception) }
    end
  end

  def initialize
    @records = []
  end

  def record(template, options, faml_result, example)
    m = example.location.match(/\A(.+):(\d+)\z/)
    @records.push(Record.new(template, options, m[1], m[2].to_i, faml_result, render_haml(template, options), render_hamlit(template, options)))
  end

  def write_to(markdown_root)
    markdown_root = Pathname.new(markdown_root)

    incompatibilities = Hash.new { |h, k| h[k] = [] }
    @records.each do |record|
      if record.incompatible?
        incompatibilities[record.spec_path] << record
      end
    end

    incompatibilities.keys.sort.each do |spec_path|
      path = markdown_path(markdown_root, spec_path)
      path.parent.mkpath
      path.open('w') do |f|
        incompatibilities[spec_path].sort_by(&:line_number).each do |record|
          render_difference(f, path, record)
        end
      end
    end
    render_toc(markdown_root, incompatibilities)
  end

  private

  def render_haml(template, options)
    obj = Object.new
    Haml::Engine.new(template, { ugly: true, escape_html: true }.merge(options)).def_method(obj, :haml)
    obj.haml
  rescue StandardError, SyntaxError => e
    e
  end

  def render_hamlit(template, options)
    obj = Object.new
    obj.instance_eval "def hamlit; #{Hamlit::Engine.new(options).call(template)}; end"
    obj.hamlit
  rescue StandardError, SyntaxError => e
    e
  end

  def render_difference(file, path, record)
    spec_path = Pathname.new(record.spec_path).relative_path_from(path.parent).to_s
    file.write <<"EOS"
# [#{record.spec_path}:#{record.line_number}](#{spec_path}#L#{record.line_number})
## #{render_input_title(record.options)}
```haml
#{record.template}
```

EOS
    render_grouped_difference(file, record.grouped_difference)
  end

  def render_input_title(options)
    title = 'Input'
    unless options.empty?
      title << " (with options=#{options.inspect})"
    end
    title
  end

  def render_grouped_difference(file, grouped_results)
    grouped_results.each do |title, result|
      file.write <<"EOS"
## #{render_section(title, result)}
```html
#{result}
```

EOS
    end
  end

  def render_section(title, result)
    if result.is_a?(Exception)
      "#{title} (Error)"
    else
      title
    end
  end

  def markdown_path(markdown_root, spec_path)
    markdown_root.join(spec_path).sub_ext('.md')
  end

  def render_toc(markdown_root, incompatibilities)
    toc_path = markdown_root.join('README.md')
    toc_path.open('w') do |f|
      f.puts '# Incompatibilities'
      f.puts '## Versions'
      f.puts "- Haml #{Haml::VERSION}"
      f.puts "- Faml #{Faml::VERSION}"
      f.puts "- Hamlit #{Hamlit::VERSION}"
      f.puts
      f.puts '## Table of contents'
      incompatibilities.keys.sort.each do |spec_path|
        path = markdown_path(markdown_root, spec_path).relative_path_from(markdown_root)
        link = "[#{path}](#{path})"
        comment =
          if incompatibilities[spec_path].all?(&:only_hamlit?)
            " (Hamlit's incompatibility)"
          end
        f.puts "- #{link}#{comment}"
      end
    end
  end
end
