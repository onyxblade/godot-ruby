module Godot
  module Object
    module InstanceMethods
      attr_accessor :godot_pointer

      def method_missing name, *args, &block
        if respond_to? name
          puts "super to Godot::Object will lead to endless loop"
        else
          call_native name, args
        end
      end
    end

    module ClassMethods
      alias :name :to_s

      def extends name
        @base_name = name
      end

      def base_name
        @base_name || 'Object'
      end
    end

    def self.included base
      base.include InstanceMethods
      base.extend ClassMethods
    end

  end
end
