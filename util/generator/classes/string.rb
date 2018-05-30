module Godot::Generator
  module Classes
    class String < Godot::Generator::Class::Heap
      ID = 4

      def initializer_function
        super <<~EOF
          api->godot_string_new(addr);

          char* str = StringValuePtr(value);
          int len = RSTRING_LEN(value);

          api->godot_string_parse_utf8_with_len(addr, str, len);
        EOF
      end

      def type_checker
        '::String'
      end
    end
  end
end
