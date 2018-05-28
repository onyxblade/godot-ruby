module GodotType
  module Types
    class Transform2D < Stack
      ID = 8

      def from_godot_function
        super(
          rotation: ['godot_real', 'godot_transform2d_get_rotation(addr)'],
          origin: ['godot_vector2', 'godot_transform2d_get_origin(addr)']
        )
      end

    end
  end
end
