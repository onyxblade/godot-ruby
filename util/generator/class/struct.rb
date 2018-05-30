module Godot::Generator
  module Class
    class Struct < Base
      def instance_functions_from_header
        api_functions.select(&:instance_function?)
      end

      def api_functions
        json = JSON.parse File.open("/home/cichol/godot_headers/gdnative_api.json", &:read)
        api_functions = json['core']['api'].select{|x| x['name'].match(/#{type_name}_/)}
        api_functions.map{|x| Godot::Generator::Function.new(x)}
      end

      def instance_methods
        api_functions.select(&:method?)
      end

      def instance_functions
        instance_methods.map do |func|
          params = func.arguments_without_self.map{|arg| "VALUE #{arg.name}"}.join(', ')
          args = func.arguments_without_self.map{|arg| arg.type.to_godot arg.name}.join(', ')

          if func.return_type
            <<~EOF
              VALUE rb_#{func.name} (#{params}) {
                #{func.return_type.signature} value = api->#{func.name}(#{args});
                return #{func.return_type.from_godot('value')};
              }
            EOF
          else
            <<~EOF
              VALUE rb_#{func.name} (#{params}) {
                api->#{func.name}(#{args});
                return Qnil;
              }
            EOF
          end
        end
      end

    end
  end
end
