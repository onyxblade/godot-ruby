module GodotType
  class Struct < Base
    def instance_functions_from_header
      api_functions.select(&:instance_function?)
    end

    def api_functions
      json = JSON.parse File.open("/home/cichol/godot_headers/gdnative_api.json", &:read)
      api_functions = json['core']['api'].select{|x| x['name'].match(/godot_#{c_name}_/)}
      # for godot_basis_new and new_identity
      api_functions.map{|x| GodotType::Function.new(x)}
    end

    def instance_functions
      instance_functions_from_header.map do |defn|
        params = defn.arguments.map do |x|
          "VALUE #{x[1]}"
        end.join(', ')

        next if !defn.arguments.all?{|x| get_class(x[0])}

        args = defn.arguments.map do |x|
          get_class(x[0]).to_godot_call(x[1])
        end.join(', ')
        if defn.return_type == 'void'
          <<~EOF
            VALUE rb_#{defn.name} (#{params}) {
              api->#{defn.name}(#{args});
              return Qnil;
            }
          EOF
        else
          return_class = get_class(defn.return_type)
          next if !return_class
          <<~EOF
            VALUE rb_#{defn.name} (#{params}) {
              #{defn.return_type} value = api->#{defn.name}(#{args});
              return #{return_class.from_godot_call('&value')};
            }
          EOF
        end
      end
    end
  end
end
