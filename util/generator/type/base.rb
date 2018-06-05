module Godot::Generator
  module Type
    class Base
      def initialize signature, **options
        @signature = signature
        @options = options
      end

      def signature
        @signature.gsub('const ', '')
      end

      def name
        @signature.gsub(' ', '_').gsub('*', 'pointer')
      end
      alias :type_name :name

      def source_classes
        [@options[:source_class]].flatten.compact
      end

      def from_godot_function
        <<~EOF
          VALUE rb_#{type_name}_from_godot (#{signature} addr) {
            return #{from_godot_body 'addr'};
          }
        EOF
      end

      def from_godot_function_header
        "VALUE rb_#{type_name}_from_godot (#{signature});"
      end

      def to_godot_function
        <<~EOF if respond_to? :to_godot
          #{signature} rb_#{type_name}_to_godot (VALUE self) {
            return #{to_godot_body 'self'};
          }
        EOF
      end

      def to_godot name
        "rb_#{type_name}_to_godot(#{name})"
      end

      def from_godot name
        "rb_#{type_name}_from_godot(#{name})"
      end

      def to_godot_function_header
        "#{signature} rb_#{type_name}_to_godot (VALUE);"
      end

    end
  end
end
