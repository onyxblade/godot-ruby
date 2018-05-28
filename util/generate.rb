require 'json'

require_relative 'generator/godot_type'
require_relative 'generator/godot_type/base/base'
require_relative 'generator/godot_type/base/function'
require_relative 'generator/godot_type/base/struct'
require_relative 'generator/godot_type/base/simple'
require_relative 'generator/godot_type/base/stack'
require_relative 'generator/godot_type/base/heap'

Dir.glob("#{__dir__}/generator/godot_type/types/*.rb").each do |file|
  require file
end

#p GodotType::Types::Transform2D.instance.api_functions.select(&:constructor?)

File.open("../example/src/godot-ruby/generated/built_in_types.c", 'w'){|f|
  f.write "extern const godot_gdnative_core_api_struct *api;\n"
  f.write GodotType.generate_functions
}
File.open("../lib/godot/generated/built_in_types.rb", 'w'){|f| f.write GodotType.generate_classes }
