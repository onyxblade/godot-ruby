=begin
module Godot::Generator
  module Classes
    class Dictionary < Godot::Generator::Class::Heap
      ID = 19

      def initializer_function
        super <<~EOF
          api->godot_dictionary_new(addr);

          VALUE pairs = rb_funcall(value, rb_intern("to_a"), 0);

          for (int i=0; i < RARRAY_LEN(pairs); ++i) {
            godot_variant key, value;
            VALUE pair = RARRAY_AREF(pairs, i);
            key = gdrb_ruby_builtin_to_godot_variant(RARRAY_AREF(pair, 0));
            value = gdrb_ruby_builtin_to_godot_variant(RARRAY_AREF(pair, 1));
            api->godot_dictionary_set(addr, &key, &value);
            api->godot_variant_destroy(&key);
            api->godot_variant_destroy(&value);
          }
        EOF
      end

      def type_checker
        '::String'
      end

    end
  end
end
=end
