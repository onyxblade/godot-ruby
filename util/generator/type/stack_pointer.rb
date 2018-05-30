module Godot::Generator
  module Type
    class StackPointer < Struct
      def from_godot_function
        <<~EOF
          VALUE rb_#{type_name}_from_godot (#{signature} addr) {
            #{signature_without_star} *naddr = api->godot_alloc(sizeof(#{signature_without_star}));
            memcpy(naddr, addr, sizeof(#{signature_without_star}));
            VALUE obj = rb_funcall(#{target_class_name}_class, rb_intern("_allocate_and_set_address"), 1, LONG2NUM((long)naddr));
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

      def type_checker
        super + ["Godot::#{target_class_name}"]
      end

    end
  end
end
