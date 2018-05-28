module GodotType
  module Types
    class Basis < Stack
      ID = 12

      def from_godot_function
        super(
          euler: ['godot_vector3', 'godot_basis_get_euler(addr)']
        )
      end

    end
  end
end
