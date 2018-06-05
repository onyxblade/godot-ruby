
module Godot::Generator
  module Type
    class WcharT < Base
      def initialize
        @signature = 'wchar_t'
      end

      def to_godot_body name
        "NUM2DBL(#{name})"
      end

      def from_godot_body name
        "rb_wchar_t_pointer_from_godot(&#{name})"
      end

    end

  end
end
