module Godot::Generator
  module Class
    class String < Godot::Generator::Class::Heap

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

      def source_classes
        '::String'
      end

      def instance_functions
        to_s = <<~EOF
          VALUE rb_#{type_name}_to_s(VALUE self) {
            godot_string *str = rb_godot_string_pointer_to_godot(self);
            VALUE ruby_str;
            godot_char_string char_string = api->godot_string_utf8(str);
            const char *chars = api->godot_char_string_get_data(&char_string);
            int len = api->godot_char_string_length(&char_string);
            ruby_str = rb_utf8_str_new(chars, len);
            api->godot_char_string_destroy(&char_string);
            return ruby_str;
          }
        EOF

        super.concat([to_s])
      end

      def register_method_statements
        to_s = "rb_define_method(#{name}_class, \"to_s\", &rb_#{type_name}_to_s, 0);"

        super.concat([to_s])
      end

    end
  end
end
