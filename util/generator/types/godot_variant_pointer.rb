module Godot::Generator
  module Type
    class GodotVariantPointer < Base
      def initialize
        @signature = 'godot_variant *'
      end

      def to_godot_body name
        "&rb_godot_variant_to_godot(#{name})"
      end

      def from_godot_body name
        "rb_godot_variant_from_godot(*#{name})"
      end

      def source_classes
        []
      end

      def to_godot_function
      end

      def to_godot_function_header
      end
    end

  end
end
