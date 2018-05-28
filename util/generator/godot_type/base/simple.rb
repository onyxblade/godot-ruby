module GodotType
  class Simple < Base
    def functions
    end

    def register_method_statements
    end

    def class_definition
    end

    def instance_functions
    end

    def from_godot_call name
      name.gsub('&', '')
    end

    def to_godot_call name
      name.gsub('&', '')
    end
  end
end
