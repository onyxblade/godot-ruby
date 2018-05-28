module GodotType
  module Types
    class Wchar_t < Simple
      def from_godot_function
        <<~EOF
          VALUE rb_godot_wchar_t_from_godot (wchar_t *addr) {
            VALUE godot_module = rb_const_get(rb_cModule, rb_intern("Godot"));
            VALUE string_class = rb_const_get(godot_module, rb_intern("String"));
            godot_string str;
            api->godot_string_new_with_wide_string(&str, addr, 1);
            VALUE obj = rb_funcall(string_class, rb_intern("allocate"), 0);
            return rb_iv_set(obj, "@_godot_address", LONG2NUM((long)&str));
          }
        EOF
      end

      def functions
        from_godot_function
      end

      def from_godot_call name
        "rb_godot_wchar_t_from_godot(#{name})"
      end
    end
  end
end
