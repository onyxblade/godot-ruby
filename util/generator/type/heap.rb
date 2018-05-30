module Godot::Generator
  module Type
    class Heap < Struct
      def from_godot_function
        <<~EOF
          VALUE rb_#{type_name}_from_godot (#{signature} addr) {
            #{signature_without_star} copy;
            api->#{signature_without_star}_new_copy(&copy, addr);
            VALUE obj = rb_funcall(#{target_class_name}, rb_intern("_allocate_and_set_address"), 1, LONG2NUM((long)addr));
            return obj;
          }
        EOF
      end

      def to_godot_function
        <<~EOF
          #{signature} rb_#{type_name}_to_godot (VALUE self) {
            VALUE addr = rb_iv_get(self, "@_godot_address");
            return (#{signature})NUM2LONG(addr);
          }
        EOF
      end

    end
  end
end
