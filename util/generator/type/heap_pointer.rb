module Godot::Generator
  module Type
    class HeapPointer < Struct
      # emmmm godot_object* is merely a void*
      def from_godot_function_for_object
        <<~EOF
          VALUE rb_#{type_name}_from_godot (#{signature} addr) {
            VALUE obj = rb_funcall(#{target_class_name}_class, rb_intern("_adopt"), 1, LONG2NUM((long)addr));
            return obj;
          }
        EOF
      end

      def from_godot_function
        return from_godot_function_for_object if target_class_name == 'Object'
        <<~EOF
          VALUE rb_#{type_name}_from_godot (#{signature} addr) {
            #{signature} naddr = api->godot_alloc(sizeof(#{signature_without_star}));
            memcpy(naddr, addr, sizeof(#{signature_without_star}));
            // will copy increase the reference count?
            // api->#{type_name.gsub('_pointer', '')}_new_copy(naddr, addr);
            VALUE obj = rb_funcall(#{target_class_name}_class, rb_intern("_adopt"), 1, LONG2NUM((long)naddr));
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
