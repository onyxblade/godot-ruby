require 'json'

class GodotBuiltInClass
  def initialize name, type
    @@classes ||= {}
    @name = name
    @@classes["godot_#{c_name}"] = self
    @type = type
  end

  def c_name
    @name.downcase
  end

  def get_constructors
    json = JSON.parse File.open("D:/godot_headers/gdnative_api.json", &:read)
    constructors = json['core']['api'].select{|x| x['name'].match(/godot_#{c_name}_new($|_with)/)}
    constructors
  end

  def strip_type_sign sign
    sign.gsub('const', '').gsub(' ', '').gsub('*', '')
  end

  def get_klass sign
    sign = strip_type_sign sign
    @@classes[sign]
  end

  def initialize_definitions
    case @type
    when :stack
      get_constructors.map do |defn|
        next if defn['name'] == 'godot_basis_new'
        actual_arguments = defn['arguments'][1..-1]
        params = actual_arguments.map{|arg|
          "VALUE #{arg[1]}"
        }.join(', ')
        args = actual_arguments.map{|arg|
          klass = get_klass arg[0]
          klass.to_godot_call arg[1]
        }.join(', ')

        function_name = defn['name'].gsub('new', 'initialize')
        <<~EOF
          VALUE rb_#{function_name}(VALUE self, #{params}){
            godot_#{c_name} *addr = api->godot_alloc(sizeof(godot_#{c_name}));
            api->godot_vector2_new(addr, #{args});
            return rb_iv_set(self, "@_godot_address", LONG2NUM((long)addr));
          }
        EOF
      end.join("\n")
    when :heap
      <<~EOF
        VALUE rb_godot_#{c_name}_initialize(VALUE self){
          godot_#{c_name} addr;
          api->godot_#{c_name}_new(&addr);
          return rb_iv_set(self, "@_godot_address", LONG2NUM((long)&addr));
        }
      EOF
    end
  end

  def declare_simple_from_godot &block
    @simple_from_godot = block
  end

  def declare_simple_to_godot &block
    @simple_to_godot = block
  end

  def declare_from_godot args
    @from_godot_args = args
  end

  def from_godot_call name
    case @type
    when :simple
      @simple_from_godot.call name
    else
      "rb_godot_#{c_name}_from_godot(#{name})"
    end
  end

  def to_godot_call name
    case @type
    when :simple
      @simple_to_godot.call name
    else
      "rb_godot_#{c_name}_to_godot(#{name})"
    end
  end

  def finalize_definition
    case @type
    when :stack
      <<~EOF
        VALUE rb_godot_#{c_name}_finalize (VALUE self) {
          VALUE addr = rb_iv_get(self, "@_godot_address");
          api->godot_free((void*)NUM2LONG(addr));
          return Qtrue;
        }
      EOF
    when :heap
      <<~EOF
        VALUE rb_godot_#{c_name}_finalize (VALUE self) {
          VALUE addr = rb_iv_get(self, "@_godot_address");
          api->godot_#{c_name}_destroy(addr);
          return Qtrue;
        }
      EOF
    end
  end

  def to_godot_definition
    <<~EOF
      godot_#{c_name} *rb_godot_#{c_name}_to_godot (VALUE self) {
        VALUE addr = rb_iv_get(self, "@_godot_address");
        return (godot_#{c_name}*)NUM2LONG(addr);
      }
    EOF
  end

  def from_godot_definition
    case @type
    when :stack
      args_statements = @from_godot_args.map do |name, (type, expr)|
        "#{type} #{name} = api->#{expr};"
      end.join("\n")
      args = @from_godot_args.map do |name, (type, expr)|
        @@classes[type].from_godot_call("&#{name}")
      end.join(', ')
      <<~EOF
        VALUE rb_godot_#{c_name}_from_godot (godot_#{c_name} *addr) {
          VALUE godot_module = rb_const_get(rb_cModule, rb_intern("Godot"));
          VALUE #{c_name}_class = rb_const_get(godot_module, rb_intern("#{@name}"));
          #{args_statements}
          return rb_funcall(#{c_name}_class, rb_intern("new"), #{@from_godot_args.size}, #{args});
        }
      EOF
    when :heap
    end
  end

  def simple?
    @type == :simple
  end

  def definitions
    [initialize_definitions, to_godot_definition, from_godot_definition, finalize_definition].flatten.join("\n") if !simple?
  end
end

def declare name, type, &block
  klass = GodotBuiltInClass.new name, type
  klass.instance_eval(&block)
  puts klass.definitions
end

declare :Real, :simple do
  declare_simple_from_godot do |name|
    "DBL2NUM(#{name})"
  end

  declare_simple_to_godot do |name|
    "NUM2DBL(#{name})"
  end
end

declare :Vector2, :stack do
  declare_from_godot(
    x: ['godot_real', 'godot_vector2_get_x(addr)'],
    y: ['godot_real', 'godot_vector2_get_y(addr)']
  )
end

declare :Vector3, :stack do
  declare_from_godot(
    x: ['godot_real', 'godot_vector3_get_axis(addr, GODOT_VECTOR3_AXIS_X)'],
    y: ['godot_real', 'godot_vector3_get_axis(addr, GODOT_VECTOR3_AXIS_Y)'],
    z: ['godot_real', 'godot_vector3_get_axis(addr, GODOT_VECTOR3_AXIS_Z)'],
  )
end

declare :Aabb, :stack do
  declare_from_godot(
    position: ['godot_vector3', 'godot_aabb_get_position(addr)'],
    size: ['godot_vector3', 'godot_aabb_get_size(addr)']
  )
end

declare :Quat, :stack do
  declare_from_godot(
    x: ['godot_real', 'godot_quat_get_x(addr)'],
    y: ['godot_real', 'godot_quat_get_y(addr)'],
    z: ['godot_real', 'godot_quat_get_z(addr)'],
    w: ['godot_real', 'godot_quat_get_w(addr)']
  )
end

declare :Basis, :stack do
  declare_from_godot(
    euler: ['godot_vector3', 'godot_basis_get_euler(addr)']
  )
end

declare :Color, :stack do
  declare_from_godot(
    r: ['godot_real', 'godot_color_get_r(addr)'],
    g: ['godot_real', 'godot_color_get_g(addr)'],
    b: ['godot_real', 'godot_color_get_b(addr)'],
    a: ['godot_real', 'godot_color_get_a(addr)'],
  )
end

declare :Plane, :stack do
  declare_from_godot(
    normal: ['godot_vector3', 'godot_plane_get_normal(addr)'],
    d: ['godot_real', 'godot_plane_get_d(addr)']
  )
end

declare :Rect2, :stack do
  declare_from_godot(
    position: ['godot_vector2', 'godot_rect2_get_position(addr)'],
    size: ['godot_vector2', 'godot_rect2_get_size(addr)']
  )
end

declare :Transform, :stack do
  declare_from_godot(
    basis: ['godot_basis', 'godot_transform_get_basis(addr)'],
    origin: ['godot_vector3', 'godot_transform_get_origin(addr)']
  )
end

declare :Transform2D, :stack do
  declare_from_godot(
    rotation: ['godot_real', 'godot_transform2d_get_rotation(addr)'],
    origin: ['godot_vector2', 'godot_transform2d_get_origin(addr)']
  )
end

=begin
declare :String, :heap do
  declare_to_godot <<~EOF

  EOF
end
=end