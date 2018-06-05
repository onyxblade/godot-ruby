module Godot::Generator
  module Type
    class Stack < Base
      def initialize signature
        @signature = signature
      end

      def from_godot_body name
        "rb_#{self.name}_pointer_from_godot(&#{name})"
      end

      def to_godot_body name
        "*rb_#{self.name}_pointer_to_godot(#{name})"
      end
    end
  end
end
