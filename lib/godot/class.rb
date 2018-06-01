module Godot
  class Class
    def initialize name
      @name = name
    end

    def new
      ClassDB.instance(String.new("Node"))
    end
  end
end
