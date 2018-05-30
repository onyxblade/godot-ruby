module Godot::Generator
  class Function
    def initialize defn
      @defn = defn
    end

    def name
      @defn['name']
    end

    def return_type
      if @defn['return_type'] == 'void'
        nil
      else
        Godot::Generator::Type.get_type @defn['return_type']
      end
    end

    def with_self?
      @defn['arguments'].first[1].match(/self/)
    end

    def instance_function?
      !name.match("_new")
    end

    def arguments
      @defn['arguments'].map{|type, name| Argument.new(type, name)}
    end

    def arguments_without_self
      arguments[1..-1]
    end

    def method?
      instance_function?
    end

    def constructor?
      name.match(/_new/) && arguments.size > 1
    end
  end

end
