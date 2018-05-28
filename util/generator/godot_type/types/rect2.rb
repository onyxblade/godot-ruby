module GodotType
  module Types
    class Rect2 < Stack
      ID = 6

      def from_godot_function
        super(
          position: ['godot_vector2', 'godot_rect2_get_position(addr)'],
          size: ['godot_vector2', 'godot_rect2_get_size(addr)']
        )
      end

    end
  end
end
