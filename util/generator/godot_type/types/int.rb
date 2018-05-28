module GodotType
  module Types
    class Int < Simple
      ID = 2

      def from_godot_call name
        "LONG2NUM(#{super name})"
      end

      def to_godot_call name
        "NUM2LONG(#{super name})"
      end

      def type_checker
        'Numeric'
      end

    end
  end
end
