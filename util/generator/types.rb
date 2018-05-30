
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
  'wchar_t *',
  from_godot_function: -> {
    <<~EOF
      VALUE rb_godot_wchar_t_from_godot (wchar_t *addr) {
        VALUE godot_module = rb_const_get(rb_cModule, rb_intern("Godot"));
        VALUE string_class = rb_const_get(godot_module, rb_intern("String"));
        godot_string str;
        api->godot_string_new_with_wide_string(&str, addr, 1);
        VALUE obj = rb_funcall(string_class, rb_intern("_allocate_and_set_address"), 1, LONG2NUM((long)&str));
        return obj;
      }
    EOF
  }
)
