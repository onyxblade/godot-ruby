module Godot
  LINKS = {}
  CLASSES = {}

  def self.require_script raw_path
    path = raw_path.gsub('res:/', ROOT)
    klass = instance_eval File.open(path, &:read), raw_path
    raise unless klass.is_a? Class
    CLASSES[klass.object_id] = klass
    klass
  end
end

require_relative "godot/built_in_type.rb"
require_relative "godot/built_in_types/object.rb"
require_relative "godot/generated/built_in_types.rb"

Dir.glob("#{__dir__}/godot/**/*.rb").each do |file|
  require file
end
