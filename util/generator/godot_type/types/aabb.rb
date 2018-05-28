module GodotType
  module Types
    class Aabb < Stack
      ID = 11

      def from_godot_function
        super(
          position: ['godot_vector3', 'godot_aabb_get_position(addr)'],
          size: ['godot_vector3', 'godot_aabb_get_size(addr)']
        )
      end

    end
  end
end
