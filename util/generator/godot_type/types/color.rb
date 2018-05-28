module GodotType
  module Types
    class Color < Stack
      ID = 14

      def from_godot_function
        super(
          r: ['godot_real', 'godot_color_get_r(addr)'],
          g: ['godot_real', 'godot_color_get_g(addr)'],
          b: ['godot_real', 'godot_color_get_b(addr)'],
          a: ['godot_real', 'godot_color_get_a(addr)'],
        )
      end

    end
  end
end
