module Godot
  module AttachedScript
    module ClassMethods
      attr_reader :_exports, :_signals

      def extends name
        @_base_name = name.to_s
      end

      def export name, as:
        @_exports ||= []
        @_exports << {name: name, as: as}
      end

      def signal name
        @_signals ||= []
        @_signals << name
      end

      def _base_name
        @_base_name || 'Object'
      end

      def tool
        @_tool = true
      end
    end

    module InstanceMethods
      def initialize
        Godot._register_object self
      end
    end

    def self.included base
      base.extend ClassMethods
      base.include InstanceMethods
    end
  end
end
