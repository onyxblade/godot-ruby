module Godot::Generator
  module Class
    class Heap < Struct
      def initializer_function initializer = nil
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
        initializer = "rb_define_method(#{name}_class, \"_initialize\", &rb_#{type_name}_initialize, 1);"
        methods = instance_methods.map do |func|
          method_name = "#{func.name.gsub("#{type_name}_", '')}"
          "rb_define_method(#{name}_class, \"#{method_name}\", &rb_#{type_name}_#{method_name}, #{func.arguments.size - 1});"
        end
        finalizer = "rb_define_singleton_method(#{name}_class, \"_finalize\", &rb_#{type_name}_finalize, 0);"
        type_func = "rb_define_method(#{name}_class, \"_type\", &rb_#{type_name}_type, 0);"
        [initializer, methods, finalizer, type_func].flatten
      end

      def class_definition
        <<~EOF
          module Godot
            class #{name} < Godot.built_in_type_class
              #{initialize_method}
            end
          end
        EOF
      end

      def initializer_functions
        [initializer_function]
      end

      def functions
        [initializer_function, to_godot_function, from_godot_function, finalizer_function].flatten.join("\n")
      end

      #def instance_functions
      #end

      def to_godot_call name
        "rb_godot_#{c_name}_to_godot(#{name})"
      end

      def from_godot_call name
        "rb_godot_#{c_name}_from_godot(#{name})"
      end
    end
  end
end
