
module Godot::Generator
  module Class
    class << self
      def get_class name
        klass = classes[name.to_s]
        raise "unknown class #{name}" unless klass
        klass
      end

      def classes
        @classes ||= Godot::Generator::Classes.constants.map{|c| Godot::Generator::Classes.const_get(c).instance}.map do |i|
          [i.name.to_s, i]
        end.to_h
      end

      def generate_class_static_definitions
        classes.values.map do |c|
          "static VALUE #{c.name}_class;"
        end
      end

      def generate_class_initialization_statements
        <<~EOF
          VALUE godot_module = rb_const_get(rb_cModule, rb_intern("Godot"));
          #{
            classes.values.map do |c|
              "#{c.name}_class = rb_const_get(godot_module, rb_intern(\"#{c.name}\"));"
            end.join("\n")
          }
        EOF
      end

      def generate_class_initializer_functions

      end

      def generate_class_finalizer_functions

      end

    end
  end
end
