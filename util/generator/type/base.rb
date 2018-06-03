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

      def from_godot name
        @options[:from_godot].call name
      end

      def to_godot name
        @options[:to_godot].call name
      end

      def type_checker
        [@options[:source_class]].flatten.compact
      end

      def from_godot_function
        return "" if @signature == 'godot_object'
        <<~EOF
          VALUE rb_#{type_name}_from_godot (#{signature} addr) {
            return #{from_godot 'addr'};
          }
        EOF
      end

      def from_godot_function_header
        return "" if @signature == 'godot_object'
        "VALUE rb_#{type_name}_from_godot (#{signature});"
      end

      def to_godot_function
        return "" if @signature == 'godot_object' || @signature == 'godot_variant *'
        <<~EOF if @options[:to_godot]
          #{signature} rb_#{type_name}_to_godot (VALUE self) {
            return #{to_godot 'self'};
          }
        EOF
      end

      def to_godot_function_header
        return "" if @signature == 'godot_object' || @signature == 'godot_variant *'
        "#{signature} rb_#{type_name}_to_godot (VALUE);"
      end

    end
  end
end
