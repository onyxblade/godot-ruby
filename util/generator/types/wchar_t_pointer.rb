
module Godot::Generator
  module Type
    class WcharTPointer < Base
      def initialize
        @signature = 'wchar_t *'
      end

      def from_godot_function
        <<~EOF
          VALUE rb_wchar_t_pointer_from_godot (wchar_t *addr) {
            godot_string str;
            api->godot_string_new_with_wide_string(&str, addr, 1);
            VALUE obj = rb_funcall(String_class, rb_intern("_adopt"), 1, LONG2NUM((long)&str));
            return obj;
          }
        EOF
      end

      def to_godot_function
      end
    end

  end
end
