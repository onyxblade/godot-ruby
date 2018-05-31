module Godot
  LINKS = {}
  CLASSES = {}

  def self.require_script raw_path
    path = raw_path.gsub('res:/', ROOT)
    klass = Class.new(Godot::Object)
    klass.class_eval(File.open(path, &:read), raw_path)
    CLASSES[klass.object_id] = klass
    klass
  end

  def self.call_method obj, name, *args
    obj.send(name, *args)
  rescue
    p $!
    p $!.backtrace
    nil
  end
end

require_relative "godot/built_in_type.rb"
require_relative "godot/object.rb"
require_relative "godot/generated/built_in_types.rb"

#Dir.glob("#{__dir__}/godot/**/*.rb").each do |file|
#  require file
#end
