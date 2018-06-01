module Godot::Generator
  module Classes
    class PoolStringArray < Godot::Generator::Class::Heap
      def initializer_function
        super <<~EOF
          api->#{type_name}_new(addr);

          for (int i=0; i < RARRAY_LEN(value); ++i) {
            godot_string *str = rb_godot_string_pointer_to_godot(RARRAY_AREF(value, i));
            api->#{type_name}_append(addr, str);
          }
        EOF
      end

      def type_name
        'godot_pool_string_array'
      end
    end
  end
end
