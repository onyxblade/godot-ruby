module Godot::Generator
  module Type
    class GodotInt < Base
      def initialize
        @signature = 'godot_int'
      end

      def to_godot_body name
        "NUM2LONG(#{name})"
      end

      def from_godot_body name
        "LONG2NUM(#{name})"
      end

      def source_classes
        ['Numeric']
      end
    end

  end
end
