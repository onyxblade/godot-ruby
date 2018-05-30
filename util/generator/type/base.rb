module Godot::Generator
  module Type
    class Base
      def initialize signature, **options
        @signature = signature
        @options = options
      end

      def signature
        @signature.gsub(' ', '')
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

    end
  end
end
