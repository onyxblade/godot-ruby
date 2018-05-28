module GodotType
  module Types
    class Transform < Stack
      ID = 13

      def from_godot_function
        super(
          basis: ['godot_basis', 'godot_transform_get_basis(addr)'],
          origin: ['godot_vector3', 'godot_transform_get_origin(addr)']
        )
      end

    end
  end
end
