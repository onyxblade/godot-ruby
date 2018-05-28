module GodotType
  module Types
    class Vector2 < Stack
      ID = 5

      METHODS = [
        :abs,
        :angle,
        :angle_to,
        :angle_to_point,
        :aspect,
        :bounce,
        :clamped,
        :cubic_interpolate,
        :distance_squared_to,
        :distance_to,
        :dot,
        :floor,
        :is_normalized,
        :length,
        :length_squared,
        :linear_interpolate,
        :normalized,
        :reflect,
        :rotated,
        :slide,
        :snapped,
        :tangent
      ]

      def from_godot_function
        super(
          x: ['godot_real', 'godot_vector2_get_x(addr)'],
          y: ['godot_real', 'godot_vector2_get_y(addr)']
        )
      end

    end
  end
end
