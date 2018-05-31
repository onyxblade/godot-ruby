extends :Object

def _ready
  @aabb = Godot::Aabb.new(Godot::Vector3.new(3, 4, 5), Godot::Vector3.new(6, 7, 8))
  @string = Godot::String.new("00000")
end

def vector
  @aabb
  Godot::Vector2.new(1,2).normalized()
  #a = Dictionary.new(a: 2, b: 'zxcv')
  #p a.keys.get(0).to_s
  #p String.new('zxcv').to_s
  #a = Array.new([String.new("abc")])
  a = Array.new([])
  a.append(String.new("abc"))
  # p a.get(0).to_s
  nil
end
