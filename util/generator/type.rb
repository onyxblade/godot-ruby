module Godot::Generator
  module Type
    class << self
      attr_reader :types

      def register_type type
        @types ||= {}
        if type.respond_to?(:spawn_type)
          sibling_type = type.spawn_type
          if sibling_type
            @types[sibling_type.signature] = sibling_type
          end
        end
        @types[type.signature] = type
      end

      def get_type signature
        signature = signature.gsub('const ', '')
        type = @types[signature]
        raise "unknown type #{signature}" unless type
        type
      end

      def generate_godot_convert_functions
        @types.values.map do |t|
          [
            t.respond_to?(:from_godot_function) && t.from_godot_function,
            t.respond_to?(:to_godot_function) && t.to_godot_function
          ]
        end.flatten.select(&:itself)
      end

      def generate_godot_convert_function_headers
        @types.values.map do |t|
          [
            t.from_godot_function_header,
            t.to_godot_function_header
          ]
        end.flatten.select(&:itself)
      end
    end
  end
end
