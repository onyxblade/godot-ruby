=begin
module Godot::Generator
  module Classes
    class Array < Godot::Generator::Class::Heap
      ID = 20

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

      def type_checker
        '::Array'
      end
    end
  end
end
=end
