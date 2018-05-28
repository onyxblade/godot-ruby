require 'json'

class GodotBuiltInClass
  attr_reader :name, :type_id

  def initialize name, type, type_id = nil
    @type_id = type_id || -1
    @@classes ||= {}
    @name = name
    @@classes["godot_#{c_name}"] = self
    @type = type
  end

  def c_name
    @name.downcase
  end

  def get_constructors
    json = JSON.parse File.open("/home/cichol/godot_headers/gdnative_api.json", &:read)
    constructors = json['core']['api'].select{|x| x['name'].match(/godot_#{c_name}_new/)}
    # for godot_basis_new and new_identity
    constructors.select{|x| x['arguments'].size > 1}
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
            api->#{defn['name']}(addr, #{args});
            return rb_iv_set(self, "@_godot_address", LONG2NUM((long)addr));
          }
        EOF
      end.join("\n")
    when :heap
      <<~EOF
        VALUE rb_godot_#{c_name}_initialize(VALUE self, VALUE value){
          godot_#{c_name} *addr = api->godot_alloc(sizeof(godot_#{c_name}));
          #{@declared_initializer}
          return rb_iv_set(self, "@_godot_address", LONG2NUM((long)addr));
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
      @simple_from_godot.call name.gsub('&', '')
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
          api->godot_#{c_name}_destroy((godot_#{c_name}*)NUM2LONG(addr));
          api->godot_free((void*)NUM2LONG(addr));
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
      <<~EOF
        VALUE rb_godot_#{c_name}_from_godot (godot_#{c_name} *addr) {
          VALUE godot_module = rb_const_get(rb_cModule, rb_intern("Godot"));
          VALUE #{c_name}_class = rb_const_get(godot_module, rb_intern("#{@name}"));
          VALUE obj = rb_funcall(#{c_name}_class, rb_intern("allocate"), 0);
          godot_#{c_name} copy;
          api->godot_#{c_name}_new_copy(&copy, addr);
          return rb_iv_set(obj, "@_godot_address", LONG2NUM((long)&copy));
        }
      EOF
    end
  end

  def simple?
    @type == :simple
  end

  def definitions
    [initialize_definitions, to_godot_definition, from_godot_definition, finalize_definition].flatten.join("\n") if !simple?
  end

  def ruby_class_name
    if simple? || @type == :heap
      @simple_ruby_class
    else
      "Godot::#{name}"
    end
  end

  def ruby_initialize_definition
    case @type
    when :stack
      branches = get_constructors.map do |defn|
        when_statement = defn['arguments'][1..-1].map.with_index do |(sign, name), index|
          "args[#{index}].is_a?(#{get_klass(sign).ruby_class_name})"
        end.join(' && ')
        "when #{when_statement} then #{defn['name'].gsub("godot_#{c_name}_new", "_initialize")}(*args)"
      end.join("\n")
    when :heap
      branches = "when args[0].is_a?(#{ruby_class_name}) then _initialize(*args)"
    end
    <<~EOF
      def initialize *args
        case
        #{branches}
        else
          raise "mismatched arguments"
        end
      end
      def _type
        #{type_id}
      end
    EOF
  end

  def ruby_definition
    <<~EOF if !simple?
      module Godot
        class #{name} < Godot::BuiltInType
          #{ruby_initialize_definition}
        end
      end
    EOF
  end

  def register_methods
    case @type
    when :simple
      return
    when :stack
      initializers = get_constructors.map do |defn|
        initializer_name = "#{defn['name'].gsub("godot_#{c_name}_new", "_initialize")}"
        "rb_define_method(#{c_name}_class, \"#{initializer_name}\", &rb_godot_#{c_name}#{initializer_name}, #{defn['arguments'].size - 1});"
      end.join("\n")
    when :heap
      initializers = "rb_define_method(string_class, \"_initialize\", &rb_godot_#{c_name}_initialize, 1);"
    end
    <<~EOF
      VALUE #{c_name}_class = rb_const_get(godot_module, rb_intern("#{name}"));
      #{initializers}
      rb_define_method(#{c_name}_class, "finalize", &rb_godot_#{c_name}_finalize, 0);
    EOF
  end

  def self.generate_c
    klasses = @@classes.values
    defns = klasses.map do |klass|
      klass.definitions
    end
    <<~EOF
      #{defns.join}
      void init() {
        VALUE godot_module = rb_const_get(rb_cModule, rb_intern("Godot"));

        #{klasses.map(&:register_methods).join}
      }
    EOF
  end

  def self.generate_ruby
    @@classes.values.map do |klass|
      klass.ruby_definition
    end.join
  end

  def declare_simple_ruby_class name
    @simple_ruby_class = name
  end

  def declare_initializer string
    @declared_initializer = string
  end
end

def declare name, type, type_id = nil, &block
  klass = GodotBuiltInClass.new name, type, type_id
  klass.instance_eval(&block)
end

declare :Real, :simple do
  declare_simple_from_godot do |name|
    "DBL2NUM(#{name})"
  end

  declare_simple_to_godot do |name|
    "NUM2DBL(#{name})"
  end

  declare_simple_ruby_class "Numeric"
end

declare :Vector2, :stack, 5 do
  declare_from_godot(
    x: ['godot_real', 'godot_vector2_get_x(addr)'],
    y: ['godot_real', 'godot_vector2_get_y(addr)']
  )
end

declare :Vector3, :stack, 7 do
  declare_from_godot(
    x: ['godot_real', 'godot_vector3_get_axis(addr, GODOT_VECTOR3_AXIS_X)'],
    y: ['godot_real', 'godot_vector3_get_axis(addr, GODOT_VECTOR3_AXIS_Y)'],
    z: ['godot_real', 'godot_vector3_get_axis(addr, GODOT_VECTOR3_AXIS_Z)'],
  )
end

declare :Aabb, :stack, 11 do
  declare_from_godot(
    position: ['godot_vector3', 'godot_aabb_get_position(addr)'],
    size: ['godot_vector3', 'godot_aabb_get_size(addr)']
  )
end

declare :Quat, :stack, 10 do
  declare_from_godot(
    x: ['godot_real', 'godot_quat_get_x(addr)'],
    y: ['godot_real', 'godot_quat_get_y(addr)'],
    z: ['godot_real', 'godot_quat_get_z(addr)'],
    w: ['godot_real', 'godot_quat_get_w(addr)']
  )
end

declare :Basis, :stack, 12 do
  declare_from_godot(
    euler: ['godot_vector3', 'godot_basis_get_euler(addr)']
  )
end

declare :Color, :stack, 14 do
  declare_from_godot(
    r: ['godot_real', 'godot_color_get_r(addr)'],
    g: ['godot_real', 'godot_color_get_g(addr)'],
    b: ['godot_real', 'godot_color_get_b(addr)'],
    a: ['godot_real', 'godot_color_get_a(addr)'],
  )
end

declare :Plane, :stack, 9 do
  declare_from_godot(
    normal: ['godot_vector3', 'godot_plane_get_normal(addr)'],
    d: ['godot_real', 'godot_plane_get_d(addr)']
  )
end

declare :Rect2, :stack, 6 do
  declare_from_godot(
    position: ['godot_vector2', 'godot_rect2_get_position(addr)'],
    size: ['godot_vector2', 'godot_rect2_get_size(addr)']
  )
end

declare :Transform, :stack, 13 do
  declare_from_godot(
    basis: ['godot_basis', 'godot_transform_get_basis(addr)'],
    origin: ['godot_vector3', 'godot_transform_get_origin(addr)']
  )
end

declare :Transform2D, :stack, 8 do
  declare_from_godot(
    rotation: ['godot_real', 'godot_transform2d_get_rotation(addr)'],
    origin: ['godot_vector2', 'godot_transform2d_get_origin(addr)']
  )
end

declare :String, :heap, 4 do
  declare_initializer <<~EOF
    api->godot_string_new(addr);

    char* str = StringValuePtr(value);
    int len = RSTRING_LEN(value);

    api->godot_string_parse_utf8_with_len(addr, str, len);
  EOF
  declare_simple_ruby_class "::String"
end

#puts GodotBuiltInClass.class_variable_get(:@@classes)['godot_string'].definitions
#puts GodotBuiltInClass.class_variable_get(:@@classes)['godot_string'].register_methods
#puts GodotBuiltInClass.class_variable_get(:@@classes)['godot_string'].ruby_definition

File.open("../example/src/godot-ruby/generated/built_in_types.c", 'w'){|f|
  f.write "extern const godot_gdnative_core_api_struct *api;\n"
  f.write GodotBuiltInClass.generate_c
}
File.open("../lib/godot/generated/built_in_types.rb", 'w'){|f| f.write GodotBuiltInClass.generate_ruby }
