require 'json'
require './../lib/godot'

BASIC_BUILT_IN_TYPES = [:null, :bool, :int, :float, :String]
VECTOR_BUILT_IN_TYPES = [:Vector2, :Rect2, :Vector3, :Transform2D, :Plane, :Quat, :AABB, :Basis, :Transform]
ENGINE_BUILT_IN_TYPES = [:Color, :NodePath, :RID, :Object]
CONTAINER_BUILT_IN_TYPES = [:Array, :PoolByteArray, :PoolIntArray, :PoolRealArray, :PoolStringArray, :PoolVector2Array, :PoolVector3Array, :PoolColorArray, :Dictionary]

json = JSON.parse File.open('/home/cichol/godot_headers/gdnative_api.json', &:read)

methods = Godot::Vector2::METHODS
names = methods.map{|x| "godot_vector2_#{x}"}

def ruby_to_godot sign, name
  case sign
  when 'const godot_vector2 *'
    %{NUM2LONG(rb_funcall(self, rb_intern("to_godot_vector2"), 0))}
  end
end

def sign_to_class sign
  case sign
  when 'godot_vector2'
    :Vector2
  end
end

def generate_binding_function defn
  params = defn['arguments'].map do |x|
    "VALUE #{x[1]}"
  end.join(', ')

  args = defn['arguments'].map do |x|
    ruby_to_godot x[0], x[1]
  end.join(', ')

  <<~EOF
    VALUE rb_#{defn['name']} (#{params}) {
      #{defn['return_type']} value = api->#{defn['name']}(#{args});
      VALUE godot_module = rb_const_get(rb_cModule, rb_intern("Godot"));
      VALUE klass = rb_const_get(godot_module, rb_intern("#{sign_to_class defn['return_type']}"));
      return rb_funcall(klass, rb_intern("from_gd"), 1, LONG2NUM(&value));
    }
  EOF
end

puts generate_binding_function json['core']['api'].select{|x| names.include? x['name']}.first
