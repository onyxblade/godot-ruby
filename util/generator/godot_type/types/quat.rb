module GodotType
  module Types
    class Quat < Stack
      ID = 10

      def from_godot_function
        super(
          x: ['godot_real', 'godot_quat_get_x(addr)'],
          y: ['godot_real', 'godot_quat_get_y(addr)'],
          z: ['godot_real', 'godot_quat_get_z(addr)'],
          w: ['godot_real', 'godot_quat_get_w(addr)']
        )
      end

    end
  end
end
