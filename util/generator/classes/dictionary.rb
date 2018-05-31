module Godot::Generator
  module Classes
    class Dictionary < Godot::Generator::Class::Heap

      def initializer_function
        super <<~EOF
          api->godot_dictionary_new(addr);

          VALUE pairs = rb_funcall(value, rb_intern("to_a"), 0);

          for (int i=0; i < RARRAY_LEN(pairs); ++i) {
            godot_variant key, value;
            VALUE pair = RARRAY_AREF(pairs, i);
            key = rb_godot_variant_to_godot(RARRAY_AREF(pair, 0));
            value = rb_godot_variant_to_godot(RARRAY_AREF(pair, 1));
            api->godot_dictionary_set(addr, &key, &value);
            api->godot_variant_destroy(&key);
            api->godot_variant_destroy(&value);
          }
        EOF
      end

      def instance_functions
        to_h = <<~EOF
          VALUE rb_#{type_name}_to_h(VALUE self) {
            godot_dictionary *dict = rb_godot_dictionary_pointer_to_godot(self);

            godot_array keys = api->godot_dictionary_keys(dict);
            godot_array values = api->godot_dictionary_values(dict);

            VALUE r_keys = rb_godot_array_pointer_from_godot(&keys);
            VALUE r_values = rb_godot_array_pointer_from_godot(&values);
            VALUE r_keys_a = rb_funcall(r_keys, rb_intern("to_a"), 0);
            VALUE r_values_a = rb_funcall(r_values, rb_intern("to_a"), 0);
            VALUE zip = rb_funcall(r_keys_a, rb_intern("zip"), 1, r_values_a);

            api->godot_array_destroy(&keys);
            api->godot_array_destroy(&values);
            return rb_funcall(zip, rb_intern("to_h"), 0);
          }
        EOF

        super.concat([to_h])
      end

      def register_method_statements
        to_h = "rb_define_method(#{name}_class, \"to_h\", &rb_#{type_name}_to_h, 0);"

        super.concat([to_h])
      end

    end
  end
end
