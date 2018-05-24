module Godot
  class Object
    class << self
      alias :name :to_s

      def extends name
        @base_name = name
      end

      def base_name
        @base_name || 'Object'
      end
    end

    def _ready

    end

    def _process

    end

    def _enter_tree

    end

    def _exit_tree

    end
  end
end
