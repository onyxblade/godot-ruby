extends :Object

signal :click, [:a, :b]

def _ready
  @aabb = Godot::Aabb.new(Godot::Vector3.new(3, 4, 5), Godot::Vector3.new(6, 7, 8))
  @string = Godot::String.new("00000")
end

def vector
  #@aabb
  #ClassDB.instance(String.new("Node"))
  #p node
  nil
end

def multi a, b
  p a + b
end
