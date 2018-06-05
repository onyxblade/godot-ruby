module Godot::Generator
  module Class
    class Base
      def name
        self.class.name.split('::').last
      end

      def type_name
        "godot_#{name.downcase}"
      end

      def type_id
        self.class.const_get(:ID)
      end

    end
  end
end
