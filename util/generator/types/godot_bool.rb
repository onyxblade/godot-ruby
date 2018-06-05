module Godot::Generator
  module Type
    class GodotBool < Base
      def initialize
        @signature = 'godot_bool'
      end

      def to_godot_body name
        "(RTEST(#{name}) ? GODOT_TRUE : GODOT_FALSE)"
      end

      def from_godot_body name
        "(#{name} ? Qtrue: Qfalse)"
      end

      def source_classes
        ['TrueClass', 'FalseClass']
      end
    end

  end
end
