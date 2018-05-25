Class.new do
  include Godot::Object
  extends :Object

  def _ready
    @vector = Godot::Vector2.new(3, 4)
    p @vector
  end

  def vector
    @vector
  end
end
