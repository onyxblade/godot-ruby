module Godot::Generator
  module Type
    class Struct < Base
      def target_class
        Godot::Generator::Class.get_class(@options[:target_class])
      end

      def target_class_name
        target_class.name.to_s
      end

      def from_godot n
        "rb_#{name}_from_godot(#{n})"
      end

      def to_godot n
        "rb_#{name}_to_godot(#{n})"
      end

      def signature_without_star
        signature.gsub('*', '')
      end

    end
  end
end
