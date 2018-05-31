module Godot::Generator
  class Function
    def initialize klass, defn
      @klass = klass
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
      !name.match("_new") && arguments[0].name.match(/self/)
    end

    def ignore_types
      [
        'char *',
        'godot_bool *',
        'double',
        'int64_t',
        'godot_int *',
        'void *',
        'godot_string_name *',
        'godot_char_string',
        'int',

        'godot_pool_byte_array',
        'godot_pool_color_array *',
        'godot_pool_vector3_array *',
        'godot_pool_vector2_array *',
        'godot_pool_string_array *',
        'godot_pool_real_array *',
        'godot_pool_int_array *',
        'godot_pool_byte_array *',
        'godot_object *',
        'uint64_t'
      ]
    end

    def ignore_functions
      ['godot_string_get_slicec']
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
      if @klass.is_a? Godot::Generator::Class::Stack
        name.match(/_new/) && arguments.size > 1
      else
        name.match(/_new/)
      end
    end

    def check_types
      if [@defn['return_type'], @defn['arguments'].map(&:first)].flatten.map{|x| x.gsub('const ', '')}.all?{|x| !ignore_types.include?(x)}
        return_type
        arguments.map(&:type)
      end
    end

    def check_ignore_function
      !ignore_functions.include?(name)
    end

    def valid?
      (constructor? || method?) && check_types && check_ignore_function
    end
  end

end
