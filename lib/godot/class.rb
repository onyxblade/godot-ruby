module Godot
  class Class
    def initialize name
      @name = name
    end

    def new
      ClassDB.instance(@name)
    end
  end
end
