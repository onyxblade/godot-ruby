module GodotType
  class Function
    def initialize defn
      @defn = defn
    end

    def name
      @defn['name']
    end

    def return_type
      @defn['return_type']
    end

    def with_self?
      @defn['arguments'].first[1].match(/self/)
    end

    def instance_function?
      !name.match("_new")
    end

    def arguments
      @defn['arguments']
    end

    def constructor?
      name.match(/_new/) && arguments.size > 1
    end
  end
end
