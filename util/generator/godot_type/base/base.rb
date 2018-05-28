module GodotType
  class Base
    def name
      self.class.name.split('::').last
    end

    def c_name
      name.downcase
    end

    def type_from_sign sign
      sign.gsub('const', '').gsub(' ', '').gsub('*', '')
    end

    def get_class sign
      @@classes ||= GodotType::Types.constants.map{|c| GodotType::Types.const_get(c)}.map{|c| [c.instance.c_name, c.instance]}.to_h.tap do |h|
        h['vector3_axis'] = h['int']
        h['signedchar'] = h['int']
      end
      @@classes[sign.gsub('const', '').gsub(' ', '').gsub('*', '').gsub('godot_', '')]
    end

    def self.instance
      @instance ||= new
    end

    def type_id
      self.class.const_get(:ID)
    end

  end
end
