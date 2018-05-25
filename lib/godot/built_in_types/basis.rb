module Godot
  class Basis < Godot::BuiltInType

    def initialize *args
      case args.size
      when 3
        initialize_with_rows *args
      when 2
        initialize_axis_and_angle *args
      when 1
        arg = args[0]
        case arg
        when Godot::Vector3
          initialize_with_euler arg
        when Godot::Quat
          initialize_with_euler_quat arg
        end
      end
    end

  end
end
