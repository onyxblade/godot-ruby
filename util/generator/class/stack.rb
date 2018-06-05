module Godot::Generator
  module Class
    class Stack < Struct
      attr_reader :name

      def initialize name
        @name = name
      end

      def initializer_functions
        constructors.map do |func|
          params = func.arguments_without_self.map{|arg| "VALUE #{arg.name}"}.join(', ')
          args = func.arguments_without_self.map{|arg| arg.type.to_godot arg.name}.join(', ')

          function_name = func.name.gsub('new', 'initialize')
          <<~EOF
            VALUE rb_#{function_name}(VALUE self, #{params}){
              #{type_name} *addr = api->godot_alloc(sizeof(#{type_name}));
              api->#{func.name}(addr, #{args});
              return rb_iv_set(self, "@_godot_address", LONG2NUM((long)addr));
            }
          EOF
        end.join("\n")
      end

      def finalizer_function
        <<~EOF
          VALUE rb_#{type_name}_finalize (VALUE self, VALUE addr) {
            api->godot_free((void*)NUM2LONG(addr));
            return Qtrue;
          }
        EOF
      end

      def initialize_method
        branches = constructors.map do |func|
          when_statement = func.arguments_without_self.map.with_index do |arg, index|
            statement = arg.type.source_classes.map{|klass| "args[#{index}].is_a?(#{klass})"}.join(" || ")
            "(#{statement})"
          end.join(' && ')
          "when #{when_statement} then #{func.name.gsub("#{type_name}_new", "_initialize")}(*args)"
        end.join("\n")
        <<~EOF
          def initialize *args
            case
            #{branches}
            else
              raise "mismatched arguments"
            end
            ObjectSpace.define_finalizer(self, self.class.finalizer_proc(@_godot_address))
          end
        EOF
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

      def register_method_statements
        initializers = constructors.map do |func|
          initializer_name = "#{func.name.gsub("#{type_name}_new", "_initialize")}"
          "rb_define_method(#{name}_class, \"#{initializer_name}\", &rb_#{type_name}#{initializer_name}, #{func.arguments.size - 1});"
        end
        methods = instance_methods.map do |func|
          method_name = "#{func.name.gsub("#{type_name}_", '')}"
          "rb_define_method(#{name}_class, \"#{method_name}\", &rb_#{type_name}_#{method_name}, #{func.arguments.size - 1});"
        end
        finalizer = "rb_define_singleton_method(#{name}_class, \"_finalize\", &rb_#{type_name}_finalize, 1);"
        type_func = "rb_define_method(#{name}_class, \"_type\", &rb_#{type_name}_type, 0);"
        [initializers, methods, finalizer, type_func].flatten
      end

      def constructors
        api_functions.select(&:constructor?)
      end

    end
  end
end
