module Godot
  LINKS = {}
  CLASSES = {}

  def self.require_script raw_path
    path = raw_path.gsub('res:/', ROOT)
    klass = Class.new(Godot::Object)
    klass.class_eval(File.open(path, &:read), raw_path)
    CLASSES[klass.object_id] = klass
    klass
  rescue
    p $!
    p $!.backtrace
    Class.new(Godot::Object)
  end

  def self.call_method obj, name, *args
    obj.send(name, *args)
  rescue
    p $!
    p $!.backtrace
    nil
  end

  def self.built_in_type_class
    @_built_in_type_class ||= Class.new do
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

        def name
          "Godot.built_in_type_class"
        end
        alias :inspect :name
        alias :to_s :name
      end

    end
  end

  def self.template_source_code base_name
    Godot::String.new <<~EOF
      extends :#{base_name}

      def _ready

      end
    EOF
  end
end

require_relative "godot/object.rb"
require_relative "godot/generated/built_in_types.rb"
