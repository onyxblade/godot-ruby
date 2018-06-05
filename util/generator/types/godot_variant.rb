module Godot::Generator
  module Type
    class GodotVariant < Base
      def initialize
        @signature = 'godot_variant'
      end

      def from_godot_function
        <<~EOF
          VALUE rb_godot_variant_from_godot (godot_variant addr) {
            VALUE ret;
            switch (api->godot_variant_get_type(&addr)) {
              case GODOT_VARIANT_TYPE_NIL:
                ret = Qnil;
                break;
              case GODOT_VARIANT_TYPE_BOOL:
                ret = #{Godot::Generator::Type.get_type('godot_bool').from_godot '(api->godot_variant_as_bool(&addr))'};
                break;
              case GODOT_VARIANT_TYPE_INT:
                ret = #{Godot::Generator::Type.get_type('godot_int').from_godot '(api->godot_variant_as_int(&addr))'};
                break;
              case GODOT_VARIANT_TYPE_REAL:
                ret = #{Godot::Generator::Type.get_type('godot_real').from_godot '(api->godot_variant_as_real(&addr))'};
                break;
              #{Godot::Generator::Class.classes.values.map{|c| c.variant_from_godot_branch}.join("\n")}
            }
            api->godot_variant_destroy(&addr);
            return ret;
          }
        EOF
      end

      def to_godot_function
        <<~EOF
          godot_variant rb_godot_variant_to_godot (VALUE self) {
            godot_variant var;
            switch (TYPE(self)) {
              case T_NIL: {
                api->godot_variant_new_nil(&var);
                break;
              }
              case T_TRUE: {
                api->godot_variant_new_bool(&var, 1);
                break;
              }
              case T_FALSE: {
                api->godot_variant_new_bool(&var, 0);
                break;
              }
              case T_FIXNUM: {
                api->godot_variant_new_int(&var, FIX2LONG(self));
                break;
              }
              case T_STRING: {
                VALUE r_str = rb_funcall(String_class, rb_intern("new"), 1, self);
                godot_string *str = rb_godot_string_pointer_to_godot(r_str);
                api->godot_variant_new_string(&var, str);
                break;
              }
              case T_FLOAT: {
                api->godot_variant_new_real(&var, RFLOAT_VALUE(self));
                break;
              }
              case T_SYMBOL: {
                VALUE _str = rb_funcall(self, rb_intern("to_s"), 0);
                VALUE r_str = rb_funcall(String_class, rb_intern("new"), 1, _str);
                godot_string *str = rb_godot_string_pointer_to_godot(r_str);
                api->godot_variant_new_string(&var, str);
                break;
              }
              case T_ARRAY: {
                VALUE r_ary = rb_funcall(Array_class, rb_intern("new"), 1, self);
                godot_array *ary = rb_godot_array_pointer_to_godot(r_ary);
                api->godot_variant_new_array(&var, ary);
                break;
              }
              case T_HASH: {
                VALUE hsh = rb_funcall(Dictionary_class, rb_intern("new"), 1, self);
                godot_dictionary *dict = rb_godot_dictionary_pointer_to_godot(hsh);
                api->godot_variant_new_dictionary(&var, dict);
                break;
              }
              default: {
                VALUE godot_module = rb_const_get(rb_cModule, rb_intern("Godot"));
                VALUE built_in_type_class = rb_funcall(godot_module, rb_intern("built_in_type_class"), 0);

                if (RTEST(rb_funcall(self, rb_intern("is_a?"), 1, built_in_type_class))) {
                  switch (FIX2LONG(rb_funcall(self, rb_intern("_type"), 0))) {
                    #{Godot::Generator::Class.classes.values.map{|c| c.variant_to_godot_branch}.join("\n")}
                    default: {
                      api->godot_print_error("unknown variant type", "", __FILE__, __LINE__);
                      api->godot_variant_new_nil(&var);
                    }
                  }
                } else {
                  VALUE _str = rb_funcall(self, rb_intern("to_s"), 0);
                  VALUE r_str = rb_funcall(String_class, rb_intern("new"), 1, _str);
                  godot_string *str = rb_godot_string_pointer_to_godot(r_str);
                  api->godot_variant_new_string(&var, str);
                }
              }
            }

            return var;
          }
        EOF
      end

      def source_classes
        ['Numeric']
      end
    end

  end
end
