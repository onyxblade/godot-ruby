module Godot
  module Generator
    def self.generate_c_functions
      File.open("../example/src/godot-ruby/generated/built_in_types.c", 'w'){|f|
        f.write "extern const godot_gdnative_core_api_struct *api;\n"
        f.write Godot::Generator::Type.generate_godot_convert_function_headers.join("\n")
        f.write Godot::Generator::Class.generate_class_static_definitions.join
        f.write Godot::Generator::Type.generate_godot_convert_functions.join
        f.write Godot::Generator::Class.generate_class_initializer_functions.join
        f.write Godot::Generator::Class.generate_class_finalizer_functions.join
        f.write Godot::Generator::Class.generate_class_instance_functions.join
        f.write Godot::Generator::Class.generate_class_type_functions.join
        f.write <<~EOF
          void init() {
            #{Godot::Generator::Class.generate_class_initialization_statements}
            #{Godot::Generator::Class.generate_class_register_method_statements.join("\n")}
          }
        EOF
      }
    end

    def self.generate_ruby_classes
      File.open("../lib/godot/generated/built_in_types.rb", 'w'){|f|
        f.write Godot::Generator::Class.generate_class_ruby_definitions.join
      }
    end
  end
end

