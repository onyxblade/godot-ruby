module Godot::Generator
  module Classes
    class NodePath < Godot::Generator::Class::Heap
      ID = 15

      def type_name
        'godot_node_path'
      end

      def initializer_function
        super <<~EOF
          godot_string temp;
          VALUE is_godot_string = rb_funcall(value, rb_intern("is_a?"), 1, String_class);
          if (RTEST(is_godot_string)) {
            api->godot_string_new_copy(&temp, rb_godot_string_pointer_to_godot(value));
          } else {
            api->godot_string_new(&temp);
            char* str = StringValuePtr(value);
            int len = RSTRING_LEN(value);

            api->godot_string_parse_utf8_with_len(&temp, str, len);
          }

          api->godot_node_path_new(addr, &temp);
          api->godot_string_destroy(&temp);
        EOF
      end

      def type_checker
        '::String'
      end
    end
  end
end
