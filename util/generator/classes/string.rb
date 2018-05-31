module Godot::Generator
  module Classes
    class String < Godot::Generator::Class::Heap
      ID = 4

      def initializer_function
        super <<~EOF
          VALUE is_godot_string = rb_funcall(value, rb_intern("is_a?"), 1, String_class);
          if (RTEST(is_godot_string)) {
            api->godot_string_new_copy(addr, rb_godot_string_pointer_to_godot(value));
          } else {
            api->godot_string_new(addr);
            char* str = StringValuePtr(value);
            int len = RSTRING_LEN(value);

            api->godot_string_parse_utf8_with_len(addr, str, len);
          }
        EOF
      end

      def type_checker
        '::String'
      end
    end
  end
end
