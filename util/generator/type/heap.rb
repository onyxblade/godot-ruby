module Godot::Generator
  module Type
    class Heap < Struct
      def from_godot_function
        <<~EOF
          VALUE rb_#{type_name}_from_godot (#{signature} addr) {
            return rb_#{type_name}_pointer_from_godot(&addr);
          }
        EOF
      end

    end
  end
end
