module Godot
  class Vector2 < Godot::BuiltInType
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

    def initialize x, y
      initialize_default x, y
    end
  end
end
