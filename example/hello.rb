Class.new do
  include Godot::Object
  extends :Object

  def _ready
    #@vector = Godot::Vector2.new(3, 4)
    @aabb = Godot::Aabb.new(Godot::Vector3.new(3, 4, 5), Godot::Vector3.new(6, 7, 8))
    p @aabb
  end

  def vector
    @aabb
  end
end
