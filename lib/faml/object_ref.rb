# frozen_string_literal: true
module Faml
  module ObjectRef
    class << self
      def render(ref = nil, prefix = nil, *)
        h = {}
        if ref.nil?
          return h
        end
        c = class_name(ref)
        i = "#{c}_#{id(ref) || 'new'}"
        if prefix
          c = "#{prefix}_#{c}"
          i = "#{prefix}_#{i}"
        end
        { id: i, class: c }
      end

      private

      def class_name(ref)
        if ref.respond_to?(:haml_object_ref)
          ref.haml_object_ref
        else
          underscore(ref.class)
        end
      end

      def id(ref)
        if ref.respond_to?(:to_key)
          key = ref.to_key
          if key
            key.join('_')
          end
        else
          ref.id
        end
      end

      def underscore(camel_cased_word)
        word = camel_cased_word.to_s.dup
        word.gsub!(/::/, '_')
        word.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
        word.tr!('-', '_')
        word.downcase!
        word
      end
    end
  end
end
