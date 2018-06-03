module Godot::Generator
  module Type
    class Alias < Base
      def alias_type
        @options[:alias_type]
      end

      def from_godot name
        alias_type.from_godot name
      end

      def to_godot name
        alias_type.to_godot name
      end

    end
  end
end
