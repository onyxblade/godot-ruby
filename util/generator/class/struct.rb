module Godot::Generator
  module Class
    class Struct < Base
      def instance_functions_from_header
        api_functions.select(&:instance_function?)
      end

      def api_functions
        json = JSON.parse File.open("/home/cichol/godot_headers/gdnative_api.json", &:read)
        api_functions = json['core']['api'].select{|x| x['name'].match(/#{type_name}_/)}
        api_functions.map{|x| Godot::Generator::Function.new(self, x)}.select(&:valid?)
      end

      def instance_methods
        api_functions.select(&:method?)
      end

      def instance_functions
        instance_methods.map do |func|
          variants = func.arguments.select{|x| x.type.name == 'godot_variant_pointer'}

          params = func.arguments.map{|arg| "VALUE #{arg.name}"}.join(', ')
          args = func.arguments.map do |arg|
            if arg.variant_pointer?
              "&#{arg.name}_v"
            else
              arg.type.to_godot arg.name
            end
          end.join(', ')

          prepare_variants = variants.map do |arg|
            "godot_variant #{arg.name}_v = rb_godot_variant_to_godot(#{arg.name});"
          end.join("\n")
          clean_up_variants = variants.map do |arg|
            "api->godot_variant_destroy(&#{arg.name}_v);"
          end.join("\n")

          if func.return_type
            <<~EOF
              VALUE rb_#{func.name} (#{params}) {
                #{prepare_variants}
                #{func.return_type.signature} value = api->#{func.name}(#{args});
                VALUE ret = #{func.return_type.from_godot('value')};
                #{clean_up_variants}
                return ret;
              }
            EOF
          else
            <<~EOF
              VALUE rb_#{func.name} (#{params}) {
                #{prepare_variants}
                api->#{func.name}(#{args});
                #{clean_up_variants}
                return Qnil;
              }
            EOF
          end
        end
      end

      def variant_type_enum_name
        "GODOT_VARIANT_TYPE_#{type_name.gsub("godot_", '')}".upcase
      end

      def variant_from_godot_branch
        <<~EOF
          case #{variant_type_enum_name}: {
            #{type_name} val = api->godot_variant_as_#{type_name.gsub('godot_', '')}(&addr);
            ret = #{Godot::Generator::Type.get_type(type_name).from_godot 'val'};
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

      def type_function
        <<~EOF
          VALUE rb_#{type_name}_type(VALUE self) {
            return LONG2FIX(#{variant_type_enum_name});
          }
        EOF
      end

    end
  end
end
