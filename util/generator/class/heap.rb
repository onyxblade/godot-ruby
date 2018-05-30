module Godot::Generator
  module Class
    class Heap < Struct
      def initializer_function initializer
        <<~EOF
          VALUE rb_#{type_name}_initialize(VALUE self, VALUE value){
            #{type_name} *addr = api->godot_alloc(sizeof(#{type_name}));
            #{initializer}
            return rb_iv_set(self, "@_godot_address", LONG2NUM((long)addr));
          }
        EOF
      end

      def finalizer_function
        <<~EOF
          VALUE rb_#{type_name}_finalize (VALUE self, VALUE addr) {
            api->#{type_name}_destroy((#{type_name}*)NUM2LONG(addr));
            api->godot_free((void*)NUM2LONG(addr));
            return Qtrue;
          }
        EOF
      end

      def initialize_method
        statement = constructor.arguments.first.type.type_checker.map{|klass| "arg.is_a?(#{klass})"}.join(" || ")
        <<~EOF
          def initialize arg
            if #{statement}
              _initialize(arg)
            else
              raise "mismatched arguments"
            end
            ObjectSpace.define_finalizer(self, self.class.finalizer_proc(@_godot_address))
          end
        EOF
      end

      def constructor
        api_functions.find{|x| x.name == "#{type_name}_new"}
      end

      def register_method_statements
        initializers = "rb_define_method(string_class, \"_initialize\", &rb_godot_#{c_name}_initialize, 1);"
        <<~EOF
          VALUE #{c_name}_class = rb_const_get(godot_module, rb_intern("#{name}"));
          #{initializers}
          rb_define_singleton_method(#{c_name}_class, "_finalize", &rb_godot_#{c_name}_finalize, 0);
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

      def functions
        [initializer_function, to_godot_function, from_godot_function, finalizer_function].flatten.join("\n")
      end

      def instance_functions
      end

      def to_godot_call name
        "rb_godot_#{c_name}_to_godot(#{name})"
      end

      def from_godot_call name
        "rb_godot_#{c_name}_from_godot(#{name})"
      end
    end
  end
end
