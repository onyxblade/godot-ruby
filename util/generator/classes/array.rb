module Godot::Generator
  module Class
    class Array < Godot::Generator::Class::Heap
      def initializer_function
        super <<~EOF
          api->godot_array_new(addr);

          for (int i=0; i < RARRAY_LEN(value); ++i) {
            godot_variant var = rb_godot_variant_to_godot(RARRAY_AREF(value, i));
            api->godot_array_append(addr, &var);
            api->godot_variant_destroy(&var);
          }
        EOF
      end

      def instance_functions
        to_a = <<~EOF
          VALUE rb_#{type_name}_to_a(VALUE self) {
            godot_array *ary = rb_godot_array_pointer_to_godot(self);
            int size = api->godot_array_size(ary);

            VALUE ruby_ary = rb_ary_new();

            for (int i=0; i < size; ++i) {
              godot_variant var = api->godot_array_get(ary, i);
              rb_ary_push(ruby_ary, rb_godot_variant_from_godot(var));
              api->godot_variant_destroy(&var);
            }

            return ruby_ary;
          }
        EOF

        super.concat([to_a])
      end

      def register_method_statements
        to_a = "rb_define_method(#{name}_class, \"to_a\", &rb_#{type_name}_to_a, 0);"

        super.concat([to_a])
      end

    end
  end
end
