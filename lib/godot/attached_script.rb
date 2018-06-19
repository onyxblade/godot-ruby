module Godot
  module AttachedScript
    module ClassMethods
      attr_reader :_exports, :_signals

      def extends name
        @_base_name = name.to_s
      end

      def export name, _type, **options
        case _type
        when :int
          type = TYPE_INT
          if options[:range]
            hint = PROPERTY_HINT_RANGE
            hint_string = [options[:range].min, options[:range].max, options[:step]].compact.join(',')
          elsif options[:enum]
            hint = PROPERTY_HINT_ENUM
            hint_string = options[:enum].join(',')
          end
        when :float
          type = TYPE_REAL
          if options[:range]
            hint = PROPERTY_HINT_RANGE
            hint_string = [options[:range].min, options[:range].max, options[:step]].compact.join(',')
          end
        when :String
          type = TYPE_STRING
          if options[:enum]
            hint = PROPERTY_HINT_ENUM
            hint_string = options[:enum].join(',')
          end
        when :exp
          type = TYPE_REAL
          hint = PROPERTY_HINT_EXP_RANGE
          hint_string = [options[:range].min, options[:range].max, options[:step]].compact.join(',')
        when :ease
          type = TYPE_REAL
          hint = PROPERTY_HINT_EXP_EASING
        when :file
          type = TYPE_STRING
          hint = PROPERTY_HINT_FILE
          if options[:extension]
            hint_string = options[:extension]
          end
        when :global_file
          type = TYPE_STRING
          hint = PROPERTY_HINT_GLOBAL_FILE
          if options[:extension]
            hint_string = options[:extension]
          end
        when :dir
          type = TYPE_STRING
          hint = PROPERTY_HINT_DIR
          if options[:extension]
            hint_string = options[:extension]
          end
        when :global_dir
          type = TYPE_STRING
          hint = PROPERTY_HINT_GLOBAL_DIR
          if options[:extension]
            hint_string = options[:extension]
          end
        when :multiline
          type = TYPE_STRING
          hint = PROPERTY_HINT_MULTILINE_TEXT
        when :rgb
          type = TYPE_COLOR
          hint = PROPERTY_HINT_COLOR_NO_ALPHA
        when :rgba
          type = TYPE_COLOR

        when :bool
          type = TYPE_BOOL
        when :Vector2
          type = TYPE_VECTOR2
        when :Rect2
          type = TYPE_RECT2
        when :Vector3
          type = TYPE_VECTOR3
        when :Transform2D
          type = TYPE_TRANSFORM2D
        when :Plane
          type = TYPE_PLANE
        when :Quat
          type = TYPE_QUAT
        when :Aabb
          type = TYPE_AABB
        when :Basis
          type = TYPE_BASIS
        when :Transform
          type = TYPE_TRANSFORM
        when :NodePath
          type = TYPE_NODE_PATH
        when :Rid
          type = TYPE_RID
        when :Dictionary
          type = TYPE_DICTIONARY
        when :Array
          type = TYPE_ARRAY
        when :PoolIntArray
          type = TYPE_INT_ARRAY
        when :PoolStringArray
          type = TYPE_STRING_ARRAY
        when :PoolVector2Array
          type = PoolVector2Array
        when :PoolVector3Array
          type = TYPE_VECTOR3_ARRAY
        when :PoolColorArray
          type = TYPE_COLOR_ARRAY

        else
          type = TYPE_OBJECT
          hint = PROPERTY_HINT_RESOURCE_TYPE
        end

        @_exports ||= []
        @_exports << {name: name, type: type, hint: hint || PROPERTY_HINT_NONE, hint_string: hint_string || '', default_value: options[:default]}
      end

      def signal name, args = []
        raise "signal arguments should be an array" if !args.is_a?(::Array)
        @_signals ||= []
        @_signals << {
          name: name,
          args: args
        }
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
