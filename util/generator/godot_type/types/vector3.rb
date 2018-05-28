module GodotType
  module Types
    class Vector3 < Stack
      ID = 7

      def from_godot_function
        super(
          x: ['godot_real', 'godot_vector3_get_axis(addr, GODOT_VECTOR3_AXIS_X)'],
          y: ['godot_real', 'godot_vector3_get_axis(addr, GODOT_VECTOR3_AXIS_Y)'],
          z: ['godot_real', 'godot_vector3_get_axis(addr, GODOT_VECTOR3_AXIS_Z)'],
        )
      end

    end
  end
end
