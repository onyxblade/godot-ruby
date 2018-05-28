Dir.glob("#{__dir__}/generator/**/*.rb").each do |file|
  require file
end

class GodotClass::Real < GodotClass::Simple
  def from_godot_call name
    "DBL2NUM(#{name})"
  end

  def to_godot_call
    "NUM2DBL(#{name})"
  end

  def type_checker
    "Numeric"
  end
end

class GodotClass::Vector < GodotClass::OnStack
  def from_godot

  end
end
