module Godot
  LINKS = {

  }
end

Dir.glob("#{__dir__}/godot/*.rb").each do |file|
  require file
end
