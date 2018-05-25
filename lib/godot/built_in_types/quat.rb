module Godot
  class Quat < Godot::BuiltInType
    def initialize *args
      case args.size
      when 4
        initialize_default *args
      when 1
        initialize_with_axis_angle *args
      end
    end
  end
end
