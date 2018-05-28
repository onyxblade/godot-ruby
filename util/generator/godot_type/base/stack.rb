module GodotType
  class Stack < Base
    def type_checker
      "Godot::#{name}"
    end

    def to_godot_call name
      "rb_godot_#{c_name}_to_godot(#{name})"
    end

    def from_godot_call name
      "rb_godot_#{c_name}_from_godot(#{name})"
    end

    def initializer_functions
      constructors_from_header.map do |defn|
        actual_arguments = defn['arguments'][1..-1]
        params = actual_arguments.map{|arg|
          "VALUE #{arg[1]}"
        }.join(', ')
        args = actual_arguments.map{|arg|
          klass = get_class arg[0]
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
    end

    def finalizer_function
      <<~EOF
        VALUE rb_godot_#{c_name}_finalize (VALUE self) {
          VALUE addr = rb_iv_get(self, "@_godot_address");
          api->godot_free((void*)NUM2LONG(addr));
          return Qtrue;
        }
      EOF
    end

    def from_godot_function from_godot_args
      args_statements = from_godot_args.map do |name, (type, expr)|
        "#{type} #{name} = api->#{expr};"
      end.join("\n")
      args = from_godot_args.map do |name, (type, expr)|
        get_class(type).from_godot_call("&#{name}")
      end.join(', ')
      <<~EOF
        VALUE rb_godot_#{c_name}_from_godot (godot_#{c_name} *addr) {
          VALUE godot_module = rb_const_get(rb_cModule, rb_intern("Godot"));
          VALUE #{c_name}_class = rb_const_get(godot_module, rb_intern("#{name}"));
          #{args_statements}
          return rb_funcall(#{c_name}_class, rb_intern("new"), #{from_godot_args.size}, #{args});
        }
      EOF
    end

    def to_godot_function
      <<~EOF
        godot_#{c_name} *rb_godot_#{c_name}_to_godot (VALUE self) {
          VALUE addr = rb_iv_get(self, "@_godot_address");
          return (godot_#{c_name}*)NUM2LONG(addr);
        }
      EOF
    end

    def initialize_method
      branches = constructors_from_header.map do |defn|
        when_statement = defn['arguments'][1..-1].map.with_index do |(sign, name), index|
          "args[#{index}].is_a?(#{get_class(sign).type_checker})"
        end.join(' && ')
        "when #{when_statement} then #{defn['name'].gsub("godot_#{c_name}_new", "_initialize")}(*args)"
      end.join("\n")
      <<~EOF
        def initialize *args
          case
          #{branches}
          else
            raise "mismatched arguments"
          end
        end
      EOF
    end

    def class_definition
      <<~EOF
        module Godot
          class #{name} < Godot::BuiltInType
            #{initialize_method}

            def _type
              #{type_id}
            end
          end
        end
      EOF
    end

    def register_method_statements
      initializers = constructors_from_header.map do |defn|
        initializer_name = "#{defn['name'].gsub("godot_#{c_name}_new", "_initialize")}"
        "rb_define_method(#{c_name}_class, \"#{initializer_name}\", &rb_godot_#{c_name}#{initializer_name}, #{defn['arguments'].size - 1});"
      end.join("\n")
      <<~EOF
        VALUE #{c_name}_class = rb_const_get(godot_module, rb_intern("#{name}"));
        #{initializers}
        rb_define_method(#{c_name}_class, "finalize", &rb_godot_#{c_name}_finalize, 0);
      EOF
    end

    def constructors_from_header
      @_constructors_from_header ||= begin
        json = JSON.parse File.open("/home/cichol/godot_headers/gdnative_api.json", &:read)
        constructors = json['core']['api'].select{|x| x['name'].match(/godot_#{c_name}_new/)}
        # for godot_basis_new and new_identity
        constructors.select{|x| x['arguments'].size > 1}
      end
    end

    def instance_functions_from_header
      @_instance_functions_from_header ||= begin
        json = JSON.parse File.open("/home/cichol/godot_headers/gdnative_api.json", &:read)
        function_names = type_methods.map{|x| "godot_#{c_name}_#{x}"}
        json['core']['api'].select{|x| function_names.include?(x['name'])}
      end
    end

    def instance_functions
      instance_functions_from_header.map do |defn|
        params = defn['arguments'].map do |x|
          "VALUE #{x[1]}"
        end.join(', ')

        args = defn['arguments'].map do |x|
          get_class(x[0]).to_godot_call(x[1])
        end.join(', ')
        p defn['return_type']
        return_class = get_class(defn['return_type'])

        <<~EOF
          VALUE rb_#{defn['name']} (#{params}) {
            #{defn['return_type']} value = api->#{defn['name']}(#{args});
            VALUE godot_module = rb_const_get(rb_cModule, rb_intern("Godot"));
            VALUE klass = rb_const_get(godot_module, rb_intern("#{return_class.name}"));
            return rb_godot_#{return_class.c_name}_from_godot(&value);
          }
        EOF
      end
    end

    def functions
      [initializer_functions, to_godot_function, from_godot_function, finalizer_function, instance_functions].flatten.join("\n")
    end

  end
end
