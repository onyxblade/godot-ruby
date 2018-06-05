module Godot::Generator
  module Type
    class GodotReal < Base
      def initialize
        @signature = 'godot_real'
      end

      def to_godot_body name
        "NUM2DBL(#{name})"
      end

      def from_godot_body name
        "DBL2NUM(#{name})"
      end

      def source_classes
        ['Numeric']
      end
    end

  end
end
