module Godot
  LINKS = {}

  def self.require_script path
    # bad pratice :(
    klass = nil
    TracePoint.trace(:class) do |tp|
      klass = tp.self
      tp.disable
    end
    require path.gsub('res:/', ROOT)
    klass
  end
end

require_relative "godot/object.rb"
Dir.glob("#{__dir__}/godot/*.rb").each do |file|
  require file
end
