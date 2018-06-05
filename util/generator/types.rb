Godot::Generator::Type.register_type(Godot::Generator::Type::GodotBool.new)

Godot::Generator::Type.register_type(Godot::Generator::Type::GodotReal.new)

Godot::Generator::Type.register_type(Godot::Generator::Type::GodotInt.new)
Godot::Generator::Type.register_type(Godot::Generator::Type::Alias.new('godot_vector3_axis', 'godot_int'))
Godot::Generator::Type.register_type(Godot::Generator::Type::Alias.new('signed char', 'godot_int'))
Godot::Generator::Type.register_type(Godot::Generator::Type::Alias.new('uint32_t', 'godot_int'))
Godot::Generator::Type.register_type(Godot::Generator::Type::Alias.new('godot_error', 'godot_int'))

Godot::Generator::Type.register_type(Godot::Generator::Type::StackPointer.new(
  'godot_aabb *',
  target_class: 'Aabb',
))

Godot::Generator::Type.register_type(Godot::Generator::Type::StackPointer.new(
  'godot_basis *',
  target_class: 'Basis'
))

Godot::Generator::Type.register_type(Godot::Generator::Type::StackPointer.new(
  'godot_color *',
  target_class: 'Color'
))

Godot::Generator::Type.register_type(Godot::Generator::Type::StackPointer.new(
  'godot_plane *',
  target_class: 'Plane'
))

Godot::Generator::Type.register_type(Godot::Generator::Type::StackPointer.new(
  'godot_quat *',
  target_class: 'Quat'
))

Godot::Generator::Type.register_type(Godot::Generator::Type::StackPointer.new(
  'godot_rect2 *',
  target_class: 'Rect2'
))

Godot::Generator::Type.register_type(Godot::Generator::Type::HeapPointer.new(
  'godot_string *',
  target_class: 'String',
  source_class: ['::String', 'Godot::String']
))

Godot::Generator::Type.register_type(Godot::Generator::Type::StackPointer.new(
  'godot_transform *',
  target_class: 'Transform'
))

Godot::Generator::Type.register_type(Godot::Generator::Type::StackPointer.new(
  'godot_transform2d *',
  target_class: 'Transform2D'
))

Godot::Generator::Type.register_type(Godot::Generator::Type::StackPointer.new(
  'godot_vector2 *',
  target_class: 'Vector2'
))

Godot::Generator::Type.register_type(Godot::Generator::Type::StackPointer.new(
  'godot_vector3 *',
  target_class: 'Vector3'
))

Godot::Generator::Type.register_type(Godot::Generator::Type::HeapPointer.new(
  'godot_node_path *',
  target_class: 'NodePath',
  source_class: ['::String', 'Godot::String']
))

Godot::Generator::Type.register_type(Godot::Generator::Type::HeapPointer.new(
  'godot_array *',
  target_class: 'Array',
  source_class: ['::Array', 'Godot::Array']
))

Godot::Generator::Type.register_type(Godot::Generator::Type::HeapPointer.new(
  'godot_dictionary *',
  target_class: 'Dictionary',
  source_class: ['::Hash', 'Godot::Dictionary']
))

Godot::Generator::Type.register_type(Godot::Generator::Type::GodotObjectPointer.new)

Godot::Generator::Type.register_type(Godot::Generator::Type::HeapPointer.new(
  'godot_pool_string_array *',
  target_class: 'PoolStringArray',
  source_class: []
))

Godot::Generator::Type.register_type(Godot::Generator::Type::GodotVariant.new)
Godot::Generator::Type.register_type(Godot::Generator::Type::GodotVariantPointer.new)

Godot::Generator::Type.register_type(Godot::Generator::Type::WcharTPointer.new)
Godot::Generator::Type.register_type(Godot::Generator::Type::WcharT.new)

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
