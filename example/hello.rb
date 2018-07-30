extends :Object

export :node, :NodePath
export :vector, :Vector2, default: Vector2.new(2, 3)

signal :click, [:a, :b]

def _ready
  @aabb = Godot::Aabb.new(Godot::Vector3.new(3, 4, 5), Godot::Vector3.new(6, 7, 8))
  @string = Godot::String.new("00000")
  @bunny_texture = ResourceLoader.load("res://icon.png")
end

def vector
  bunny = Sprite.new
  bunny.set(:texture, @bunny_texture)
  bunny.set(:position, Vector2[12, 12])
  bunny
end

def multi a, b
  p a + b
end
