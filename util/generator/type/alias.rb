module Godot::Generator
  module Type
    class Alias < Base
      def initialize signature, alias_signature
        @signature = signature
        @alias_signature = alias_signature
      end

      def from_godot_body name
        Godot::Generator::Type.get_type(@alias_signature).from_godot_body name
      end

      def to_godot_body name
        Godot::Generator::Type.get_type(@alias_signature).to_godot_body name
      end

    end
  end
end
