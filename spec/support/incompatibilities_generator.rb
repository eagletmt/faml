require 'pathname'
require 'singleton'
require 'hamlit/engine'
require 'hamlit/version'

class IncompatibilitiesGenerator
  include Singleton

  class Record < Struct.new(:template, :options, :spec_path, :line_number, :faml_result, :haml_result, :hamlit_result)
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
      if record.faml_result.is_a?(Exception) && record.haml_result.is_a?(Exception) && record.hamlit_result.is_a?(Exception)
        # All errored, not an incompatibility.
      elsif record.faml_result != record.haml_result || record.faml_result != record.hamlit_result || record.haml_result != record.hamlit_result
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
    render_toc(markdown_root, incompatibilities.keys)
  end

  private

  def render_haml(template, options)
    obj = Object.new
    Haml::Engine.new(template, {ugly: true, escape_html: true}.merge(options)).def_method(obj, :haml)
    obj.haml
  rescue Exception => e
    e
  end

  def render_hamlit(template, options)
    obj = Object.new
    obj.instance_eval "def hamlit; #{Hamlit::Engine.new(options).call(template)}; end"
    obj.hamlit
  rescue Exception => e
    e
  end

  def render_difference(file, path, record)
    spec_path = Pathname.new(record.spec_path).relative_path_from(path.parent).to_s
    file.write <<"EOS"
# [#{record.spec_path}:#{record.line_number}](#{spec_path}#L#{record.line_number})
## Input
```haml
#{record.template}
```

EOS
    if record.faml_result != record.haml_result && record.faml_result != record.hamlit_result
      render_grouped_difference(file, 'Faml' => record.faml_result, 'Haml' => record.haml_result, 'Hamlit' => record.hamlit_result)
    elsif record.faml_result == record.haml_result
      render_grouped_difference(file, 'Faml, Haml' => record.faml_result, 'Hamlit' => record.hamlit_result)
    elsif record.faml_result == record.hamlit_result
      render_grouped_difference(file, 'Faml, Hamlit' => record.faml_result, 'Haml' => record.haml_result)
    else
      render_grouped_difference(file, 'Faml' => record.faml_result, 'Haml, Hamlit' => record.haml_result)
    end
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

  def render_toc(markdown_root, spec_paths)
    toc_path = markdown_root.join('README.md')
    toc_path.open('w') do |f|
      f.puts '# Incompatibilities'
      f.puts '## Versions'
      f.puts "- Haml #{Haml::VERSION}"
      f.puts "- Faml #{Faml::VERSION}"
      f.puts "- Hamlit #{Hamlit::VERSION}"
      f.puts
      f.puts '## Table of contents'
      spec_paths.sort.each do |spec_path|
        path = markdown_path(markdown_root, spec_path).relative_path_from(markdown_root)
        f.puts "- [#{path}](#{path})"
      end
    end
  end
end
