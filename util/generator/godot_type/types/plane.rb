module GodotType
  module Types
    class Plane < Stack
      ID = 9

      def from_godot_function
        super(
          normal: ['godot_vector3', 'godot_plane_get_normal(addr)'],
          d: ['godot_real', 'godot_plane_get_d(addr)']
        )
      end

    end
  end
end
