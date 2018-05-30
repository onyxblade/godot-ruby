module Godot::Generator
  module Class
    class Stack < Struct
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
            statement = arg.type.type_checker.map{|klass| "args[#{index}].is_a?(#{klass})"}.join(" || ")
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
        initializers = constructors.map do |defn|
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
          rb_define_singleton_method(#{c_name}_class, "_finalize", &rb_godot_#{c_name}_finalize, 1);
        EOF
      end

      def constructors
        api_functions.select(&:constructor?)
      end

    end
  end
end
