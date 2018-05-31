module Godot::Generator
  module Type
    class << self
      attr_reader :types

      def register_type signature, **options
        @types ||= {}
        case options[:method]
        when :alias
          type = Godot::Generator::Type.get_type(options[:alias])
        when :stack
          type = Godot::Generator::Type::Stack.new(signature, options)
        when :stack_pointer
          type = Godot::Generator::Type::StackPointer.new(signature, options)
          s = signature.gsub(' *', '')
          Godot::Generator::Type.register_type(
            s,
            from_godot: -> name {
              "rb_#{type.name}_from_godot(&#{name})"
            }
          )
        when :heap
          type = Godot::Generator::Type::Heap.new(signature, options)
        when :heap_pointer
          type = Godot::Generator::Type::HeapPointer.new(signature, options)
          s = signature.gsub(' *', '')
          Godot::Generator::Type.register_type(
            s,
            from_godot: -> name {
              "rb_#{type.name}_from_godot(&#{name})"
            },
            to_godot: -> name {
              "*rb_#{type.name}_to_godot(#{name})"
            }
          )
        when :simple_with_function
          type = Godot::Generator::Type::SimpleWithFunction.new(signature, options)
        else
          type = Godot::Generator::Type::Base.new(signature, options)
        end
        @types[signature] = type
      end

      def get_type signature
        signature = signature.gsub('const ', '')
        type = @types[signature]
        raise "unknown type #{signature}" unless type
        type
      end

      def generate_godot_convert_functions
        @types.values.map do |t|
          [
            t.respond_to?(:from_godot_function) && t.from_godot_function,
            t.respond_to?(:to_godot_function) && t.to_godot_function
          ]
        end.flatten.select(&:itself)
      end
    end
  end
end
