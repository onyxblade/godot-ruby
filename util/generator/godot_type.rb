module GodotType
  def self.generate_functions
    klasses = GodotType::Types.constants.map{|c| GodotType::Types.const_get(c).instance}
    defns = klasses.map do |klass|
      klass.functions
    end
    <<~EOF
      #{defns.join}
      #{klasses.map{|klass| klass.instance_functions}.join}
      void init() {
        VALUE godot_module = rb_const_get(rb_cModule, rb_intern("Godot"));

        #{klasses.map(&:register_method_statements).join}
      }
    EOF
  end

  def self.generate_classes
    klasses = GodotType::Types.constants.map{|c| GodotType::Types.const_get(c).instance}
    klasses.map do |klass|
      klass.class_definition
    end.join
  end
end
