module Godot::Generator
  module Type
    class HeapPointer < Struct
      def from_godot_function
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

      def spawn_type
        Godot::Generator::Type::Heap.new(signature.gsub(' *', ''))
      end

    end
  end
end
