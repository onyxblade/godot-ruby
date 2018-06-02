module Godot
  class Object < Godot.built_in_type_class
    def method_missing name, *args, &block
      if respond_to? name
        puts "super to Godot::Object will lead to endless loop"
      else
        _call name, args
      end
    end
  end
end
