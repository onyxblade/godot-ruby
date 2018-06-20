extends :Object

export :node, :NodePath
export :vector, :Vector2, default: Vector2.new(2, 3)

signal :click, [:a, :b]

def _ready
  @aabb = Godot::Aabb.new(Godot::Vector3.new(3, 4, 5), Godot::Vector3.new(6, 7, 8))
  @string = Godot::String.new("00000")
end

def vector
  -Vector2[2, 3]
end

def multi a, b
  p a + b
end
