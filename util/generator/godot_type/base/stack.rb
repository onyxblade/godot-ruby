module GodotType
  class Stack < Struct
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
        actual_arguments = defn.arguments[1..-1]
        params = actual_arguments.map{|arg|
          "VALUE #{arg[1]}"
        }.join(', ')
        args = actual_arguments.map{|arg|
          klass = get_class arg[0]
          klass.to_godot_call arg[1]
        }.join(', ')

        function_name = defn.name.gsub('new', 'initialize')
        <<~EOF
          VALUE rb_#{function_name}(VALUE self, #{params}){
            godot_#{c_name} *addr = api->godot_alloc(sizeof(godot_#{c_name}));
            api->#{defn.name}(addr, #{args});
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

    def from_godot_function
      <<~EOF
        VALUE rb_godot_#{c_name}_from_godot (godot_#{c_name} *addr) {
          VALUE godot_module = rb_const_get(rb_cModule, rb_intern("Godot"));
          VALUE #{c_name}_class = rb_const_get(godot_module, rb_intern("#{name}"));
          godot_#{c_name} *naddr = api->godot_alloc(sizeof(godot_#{c_name}));
          memcpy(naddr, addr, sizeof(godot_#{c_name}));
          VALUE obj = rb_funcall(#{c_name}_class, rb_intern("allocate"), 0);
          rb_iv_set(obj, "@_godot_address", LONG2NUM((long)naddr));
          return obj;
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
        when_statement = defn.arguments[1..-1].map.with_index do |(sign, name), index|
          "args[#{index}].is_a?(#{get_class(sign).type_checker})"
        end.join(' && ')
        "when #{when_statement} then #{defn.name.gsub("godot_#{c_name}_new", "_initialize")}(*args)"
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
        initializer_name = "#{defn.name.gsub("godot_#{c_name}_new", "_initialize")}"
        "rb_define_method(#{c_name}_class, \"#{initializer_name}\", &rb_godot_#{c_name}#{initializer_name}, #{defn.arguments.size - 1});"
      end.join("\n")
      instance_methods = instance_functions_from_header.map do |defn|
        method_name = "#{defn.name.gsub("godot_#{c_name}_", '')}"
        "rb_define_method(#{c_name}_class, \"#{method_name}\", &rb_godot_#{c_name}_#{method_name}, #{defn.arguments.size - 1});"
      end.join("\n")
      <<~EOF
        VALUE #{c_name}_class = rb_const_get(godot_module, rb_intern("#{name}"));
        #{initializers}
        #{instance_methods}
        rb_define_method(#{c_name}_class, "finalize", &rb_godot_#{c_name}_finalize, 0);
      EOF
    end

    def constructors_from_header
      api_functions.select(&:constructor?)
    end

    def functions
      [initializer_functions, to_godot_function, from_godot_function, finalizer_function].flatten.join("\n")
    end

  end
end
