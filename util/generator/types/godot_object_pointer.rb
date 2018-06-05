module Godot::Generator
  module Type
    class GodotObjectPointer < HeapPointer
      def initialize
        super(
          'godot_object *',
          target_class: 'Object'
        )
      end

      # emmmm godot_object* is merely a void*
      def from_godot_function
        <<~EOF
          VALUE rb_#{type_name}_from_godot (#{signature} addr) {
            VALUE obj = rb_funcall(#{target_class_name}_class, rb_intern("_adopt"), 1, LONG2NUM((long)addr));
            return obj;
          }
        EOF
      end

      def spawn_type
      end

    end
  end
end
