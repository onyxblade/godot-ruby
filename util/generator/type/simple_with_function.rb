module Godot::Generator
  module Type
    class SimpleWithFunction < Base
      def from_godot_function
        @options[:from_godot_function]
      end

      def to_godot_function
        @options[:to_godot_function]
      end

      def from_godot n
        "rb_#{name}_from_godot(#{n})"
      end

      def to_godot n
        "rb_#{name}_to_godot(#{n})"
      end

    end
  end
end
