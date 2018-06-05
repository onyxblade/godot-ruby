
module Godot::Generator
  module Class
    class << self
      attr_reader :classes

      def register_class klass
        @classes ||= {}
        @classes[klass.name.to_s] = klass
      end

      def get_class name
        klass = classes[name.to_s]
        raise "unknown class #{name}" unless klass
        klass
      end

      def generate_class_static_definitions
        classes.values.map do |c|
          "static VALUE #{c.name}_class;\n"
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
        classes.values.map do |c|
          c.initializer_functions
        end
      end

      def generate_class_finalizer_functions
        classes.values.map do |c|
          c.finalizer_function
        end
      end

      def generate_class_instance_functions
        classes.values.map do |c|
          c.instance_functions
        end
      end

      def generate_class_register_method_statements
        classes.values.map do |c|
          c.register_method_statements
        end
      end

      def generate_class_ruby_definitions
        classes.values.map do |c|
          c.class_definition
        end
      end

      def generate_class_type_functions
        classes.values.map do |c|
          c.type_function
        end
      end

    end
  end
end
