module Godot
  def self._register_class path, code
    @_classes ||= {}
    klass = ::Class.new(Godot::Object)
    klass.include Godot::AttachedScript
    klass.class_eval(code, path)
    @_classes[klass.object_id] = klass
    klass
  rescue Exception => e
    Godot._print_error e
    klass = ::Class.new(Godot::Object)
    klass.include Godot::AttachedScript
    klass
  end

  def self._unregister_class klass
    @_classes.delete(klass.object_id)
  end

  def self.call_method obj, name, *args
    obj.send(name, *args)
  rescue Exception => e
    Godot._print_error e
    nil
  end

  def self.built_in_type_class
    @_built_in_type_class ||= ::Class.new do
      class << self
        def _adopt addr
          obj = allocate
          obj.instance_variable_set(:@_godot_address, addr)
          ObjectSpace.define_finalizer(obj, finalizer_proc(addr))
          obj
        end

        def finalizer_proc addr
          proc { self._finalize addr }
        end

        def const_missing name
          if Engine.has_singleton(name)
            Godot.const_set(name, Godot._get_singleton(name.to_s))
          else
            Godot.const_set(name, Godot::Class.new(name))
          end
        end

        def [] *args
          new *args
        end
      end

    end
  end

  def self._template_source_code base_name
    Godot::String.new <<~EOF
      extends :#{base_name}

      def _ready

      end
    EOF
  end

  def self._define_constants pool_string_array
    pool_string_array.size.times do |i|
      name = pool_string_array.get(i).to_s
      Godot.const_set(name, Godot._get_singleton(name))
    end
  end

  def self._initialize_singletons
    singletons = ["ResourceLoader", "ResourceSaver", "OS", "Geometry", "ClassDB", "Engine", "AudioServer", "ProjectSettings", "Input", "InputMap", "Marshalls", "Performance", "Physics2DServer", "PhysicsServer", "TranslationServer", "VisualServer"]
    singletons.each do |name|
      Godot.const_set(name, Godot._get_singleton(name))
    end
    ['TCPServer', 'File', 'Thread', 'Mutex', 'Range'].each do |name|
      Godot.const_set(name, Godot::Class.new(name))
    end
  end

  def self._initialize_io
    io_class = ::Class.new(IO) do
      def write data
        str = data.to_s.chomp
        unless str.empty?
          Godot._print String.new(str)
        end
      end
    end

    godot_io = io_class.new(1)
    $stdout.reopen(godot_io)
  end

  def self._initialize_constants
    @_godot_constants = @_godot_constants.to_h.map do |name, int|
      [name.to_s, int]
    end.to_h
    @_godot_constants.each do |name, int|
      Godot.const_set(name, int)
    end
  end

  def self._initialize
    _initialize_singletons
    _initialize_io
    _initialize_constants
  rescue Exception => e
    Godot._print_error e
  end

  def self._register_object obj
    @_objects ||= {}
    @_objects[obj.object_id] = obj
  end

  def self._unregister_object obj
    @_objects.delete(obj.object_id)
  end

  def self._script_manifest klass
    klass.instance_eval do
      [
        #name:
        String.new('anonymous'),
        #tool:
        @_tool ? 1 : 0,
        #base:
        String.new(@_base_name || 'Object'),
        #member_lines:
        Dictionary.new({}),
        #methods:
        Array.new(instance_methods(false).map{|m|
          {
            name: m,
            args: [],
            default_args: [],
            return: {},
            flags: 1,
            rpc_mode: 0
          }
        }),
        #signals:
        Array.new(@_signals.to_a.map{|s|
          {
            name: s[:name],
            args: s[:args].map{|arg|
              {
                name: arg
              }
            },
            default_args: [],
            return: {},
            flags: 1,
            rpc_mode: 0
          }
        }),
        #properties:
        Array.new(@_exports.to_a.map{|p|
          {
            name: p[:name],
            type: p[:type],
            hint: p[:hint],
            hint_string: p[:hint_string],
            usage: 8199,
            default_value: p[:default_value],
            rset_mode: 0
          }
        })
      ]
    end
  end
end
