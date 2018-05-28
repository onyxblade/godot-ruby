module GodotType
  module Types
    class Bool < Simple
      ID = 1

      def from_godot_call name
        "(#{super name} ? Qtrue: Qfalse)"
      end

      def to_godot_call name
        "(RTEST(#{super name}) ? GODOT_TRUE : GODOT_FALSE)"
      end

      def type_checker
        Object
      end

    end
  end
end
