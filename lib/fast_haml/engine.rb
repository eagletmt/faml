require 'temple'
require 'fast_haml/compiler'
require 'fast_haml/html'
require 'fast_haml/parser'

module FastHaml
  class Engine < Temple::Engine
    define_options(
      generator: Temple::Generators::ArrayBuffer,
    )

    use Parser
    use Compiler
    use Html
    filter :Escapable
    filter :ControlFlow
    filter :MultiFlattener
    filter :StaticMerger
    use :Generator do
      options[:generator].new(options.to_hash.reject {|k,v| !options[:generator].options.valid_key?(k) })
    end

    def render(template, scope_object = Object.new, locals = {})
      scope_object.singleton_class.class_eval do
        locals.each do |k, v|
          define_method(k) do
            v
          end
        end
      end

      code = call(template)
      scope_object.instance_eval(code)
    end
  end
end
