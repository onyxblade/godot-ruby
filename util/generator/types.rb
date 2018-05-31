
Godot::Generator::Type.register_type(
  'godot_aabb *',
  target_class: 'Aabb',
  method: :stack_pointer
)

Godot::Generator::Type.register_type(
  'godot_basis *',
  target_class: 'Basis',
  method: :stack_pointer
)

Godot::Generator::Type.register_type(
  'godot_bool',
  from_godot: -> name do
    "(#{name} ? Qtrue: Qfalse)"
  end,
  to_godot: -> name do
    "(RTEST(#{name}) ? GODOT_TRUE : GODOT_FALSE)"
  end,
  source_class: ['TrueClass', 'FalseClass']
)

Godot::Generator::Type.register_type(
  'godot_color *',
  target_class: 'Color',
  method: :stack_pointer
)

Godot::Generator::Type.register_type(
  'godot_int',
  from_godot: -> name do
    "LONG2NUM(#{name})"
  end,
  to_godot: -> name do
    "NUM2LONG(#{name})"
  end,
  source_class: 'Numeric'
)
Godot::Generator::Type.register_type(
  'godot_vector3_axis',
  method: :alias,
  alias: 'godot_int'
)
Godot::Generator::Type.register_type(
  'signed char',
  method: :alias,
  alias: 'godot_int'
)

Godot::Generator::Type.register_type(
  'godot_plane *',
  target_class: 'Plane',
  method: :stack_pointer
)

Godot::Generator::Type.register_type(
  'godot_quat *',
  target_class: 'Quat',
  method: :stack_pointer
)

Godot::Generator::Type.register_type(
  'godot_real',
  from_godot: -> name do
    "DBL2NUM(#{name})"
  end,
  to_godot: -> name do
    "NUM2DBL(#{name})"
  end,
  source_class: 'Numeric'
)

Godot::Generator::Type.register_type(
  'godot_rect2 *',
  target_class: 'Rect2',
  method: :stack_pointer
)

Godot::Generator::Type.register_type(
  'godot_string *',
  target_class: 'String',
  method: :heap_pointer,
  source_class: ['::String', 'Godot::String']
)

Godot::Generator::Type.register_type(
  'godot_transform *',
  target_class: 'Transform',
  method: :stack_pointer
)

Godot::Generator::Type.register_type(
  'godot_transform2d *',
  target_class: 'Transform2D',
  method: :stack_pointer
)

Godot::Generator::Type.register_type(
  'godot_vector2 *',
  target_class: 'Vector2',
  method: :stack_pointer
)

Godot::Generator::Type.register_type(
  'godot_vector3 *',
  target_class: 'Vector3',
  method: :stack_pointer
)

Godot::Generator::Type.register_type(
  'uint32_t',
  from_godot: -> name do
    "LONG2NUM(#{name})"
  end,
  to_godot: -> name do
    "NUM2LONG(#{name})"
  end,
  source_class: 'Numeric'
)

Godot::Generator::Type.register_type(
  'godot_node_path *',
  target_class: 'NodePath',
  method: :heap_pointer,
  source_class: ['::String', 'Godot::String']
)

Godot::Generator::Type.register_type(
  'godot_variant',
  from_godot_function: ->{
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
  }.(),
  to_godot_function: ->{
    <<~EOF
      godot_variant rb_godot_variant_to_godot (VALUE self) {
        switch (TYPE(self)) {
          case T_NIL:
            return gdrb_ruby_nil_to_godot_variant();
          case T_TRUE:
            return gdrb_ruby_true_to_godot_variant();
          case T_FALSE:
            return gdrb_ruby_false_to_godot_variant();
          case T_FIXNUM:
            return gdrb_ruby_fixnum_to_godot_variant(self);
          case T_STRING:
            return gdrb_ruby_string_to_godot_variant(self);
          case T_FLOAT:
            return gdrb_ruby_float_to_godot_variant(self);
          case T_SYMBOL:
            return gdrb_ruby_symbol_to_godot_variant(self);
          case T_ARRAY:
            return gdrb_ruby_array_to_godot_variant(self);
          case T_HASH:
            return gdrb_ruby_hash_to_godot_variant(self);
          default: {
            VALUE godot_module = rb_const_get(rb_cModule, rb_intern("Godot"));
            VALUE built_in_type_class = rb_const_get(godot_module, rb_intern("BuiltInType"));

            if (RTEST(rb_funcall(self, rb_intern("is_a?"), 1, built_in_type_class))) {
              godot_variant var;
              switch (FIX2LONG(rb_funcall(self, rb_intern("_type"), 0))) {
                #{Godot::Generator::Class.classes.values.map{|c| c.variant_to_godot_branch}.join("\n")}
              }
            }
            return gdrb_ruby_string_to_godot_variant(rb_funcall(self, rb_intern("to_s"), 0));
          }
        }
      }
    EOF
  }.(),
  method: :simple_with_function
)

Godot::Generator::Type.register_type(
  'godot_variant *',
  from_godot: -> name {
    "rb_godot_variant_from_godot(*#{name})"
  },
  to_godot: -> name {
    "&rb_godot_variant_to_godot(#{name})"
  }
)

Godot::Generator::Type.register_type(
  'wchar_t *',
  from_godot_function: -> {
    <<~EOF
      VALUE rb_wchar_t_pointer_from_godot (wchar_t *addr) {
        godot_string str;
        api->godot_string_new_with_wide_string(&str, addr, 1);
        VALUE obj = rb_funcall(String_class, rb_intern("_adopt"), 1, LONG2NUM((long)&str));
        return obj;
      }
    EOF
  }.(),
  method: :simple_with_function
)

Godot::Generator::Type.register_type(
  'wchar_t',
  from_godot: -> name {
    "rb_wchar_t_pointer_from_godot(&#{name})"
  }
)

=begin


Godot::Generator::Type.register_type(
  'godot_array',
  from_godot: -> name {
    "from_array"
  },
  to_godot: -> name {
    "to_array"
  }
)

Godot::Generator::Type.register_type(
  'godot_array *',
  from_godot: -> name {
    "from_array"
  },
  to_godot: -> name {
    "to_array"
  }
)

Godot::Generator::Type.register_type(
  'godot_variant',
  from_godot: -> name {
    "from_array"
  },
  to_godot: -> name {
    "to_array"
  }
)

Godot::Generator::Type.register_type(
  'godot_variant *',
  from_godot: -> name {
    "from_array"
  },
  to_godot: -> name {
    "to_array"
  }
)

Godot::Generator::Type.register_type(
  'godot_pool_byte_array',
  from_godot: -> name {
    "from_array"
  },
  to_godot: -> name {
    "to_array"
  }
)
=end
