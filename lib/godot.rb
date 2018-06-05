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

  def self._initialize
    _initialize_singletons
    _initialize_io
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
end
