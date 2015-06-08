require 'pathname'
require 'singleton'

class IncompatibilitiesGenerator
  include Singleton

  class Record < Struct.new(:template, :options, :spec_path, :line_number, :faml_result, :haml_result)
  end

  def initialize
    @records = []
  end

  def record(template, options, faml_result, example)
    m = example.location.match(/\A(.+):(\d+)\z/)
    @records.push(Record.new(template, options, m[1], m[2].to_i, faml_result, render_haml(template, options)))
  end

  def write_to(markdown_root)
    markdown_root = Pathname.new(markdown_root)

    incompatibilities = Hash.new { |h, k| h[k] = [] }
    @records.each do |record|
      if record.faml_result.is_a?(Exception) && record.haml_result.is_a?(Exception)
        # both errored, not an incompatibility.
      elsif record.faml_result != record.haml_result
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

  def render_difference(file, path, record)
    spec_path = Pathname.new(record.spec_path).relative_path_from(path.parent).to_s
    file.write <<"EOS"
# [#{record.spec_path}:#{record.line_number}](#{spec_path}#L#{record.line_number})
## Input
```haml
#{record.template}
```

## #{render_section('Faml', record.faml_result)}
```html
#{record.faml_result}
```

## #{render_section('Haml', record.haml_result)}
```html
#{record.haml_result}
```

EOS
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
      f.puts
      f.puts '## Table of contents'
      spec_paths.sort.each do |spec_path|
        path = markdown_path(markdown_root, spec_path).relative_path_from(markdown_root)
        f.puts "- [#{path}](#{path})"
      end
    end
  end
end
