module Godot
  class BuiltInType
    def initialize
      @godot_pointer = 0
    end

    def self._adopt addr
      obj = allocate
      obj.instance_variable_set(:@_godot_address, addr)
      ObjectSpace.define_finalizer(obj, finalizer_proc(addr))
      obj
    end

    def self.finalizer_proc addr
      proc { self._finalize addr }
    end
  end
end
