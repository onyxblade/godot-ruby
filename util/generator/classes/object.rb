module Godot::Generator
  module Class
    class Object < Godot::Generator::Class::Heap
      def initializer_function
      end

      def initialize_method
      end

      def register_method_statements
        methods = instance_methods.map do |func|
          method_name = "#{func.name.gsub("#{type_name}_", '')}"
          "rb_define_method(#{name}_class, \"#{method_name}\", &rb_#{type_name}_#{method_name}, #{func.arguments.size - 1});"
        end
        finalizer = "rb_define_singleton_method(#{name}_class, \"_finalize\", &rb_#{type_name}_finalize, 0);"
        type_func = "rb_define_method(#{name}_class, \"_type\", &rb_#{type_name}_type, 0);"
        [methods, finalizer, type_func].flatten
      end

      def variant_from_godot_branch
        <<~EOF
          case #{variant_type_enum_name}: {
            #{type_name}* val = api->godot_variant_as_#{type_name.gsub('godot_', '')}(&addr);
            ret = rb_godot_object_pointer_from_godot(val);
            break;
          }
        EOF
      end

      def variant_to_godot_branch
        <<~EOF
          case #{variant_type_enum_name}: {
            #{type_name} *addr = #{Godot::Generator::Type.get_type("#{type_name} *").to_godot 'self'};
            api->godot_variant_new_#{type_name.gsub('godot_', '')}(&var, addr);
            break;
          }
        EOF
      end

    end
  end
end
