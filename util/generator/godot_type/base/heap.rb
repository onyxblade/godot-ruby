module GodotType
  class Heap < Base
    def initializer_function initializer
      <<~EOF
        VALUE rb_godot_#{c_name}_initialize(VALUE self, VALUE value){
          godot_#{c_name} *addr = api->godot_alloc(sizeof(godot_#{c_name}));
          #{initializer}
          return rb_iv_set(self, "@_godot_address", LONG2NUM((long)addr));
        }
      EOF
    end

    def finalizer_function
      <<~EOF
        VALUE rb_godot_#{c_name}_finalize (VALUE self) {
          VALUE addr = rb_iv_get(self, "@_godot_address");
          api->godot_#{c_name}_destroy((godot_#{c_name}*)NUM2LONG(addr));
          api->godot_free((void*)NUM2LONG(addr));
          return Qtrue;
        }
      EOF
    end

    def from_godot_function
      <<~EOF
        VALUE rb_godot_#{c_name}_from_godot (godot_#{c_name} *addr) {
          VALUE godot_module = rb_const_get(rb_cModule, rb_intern("Godot"));
          VALUE #{c_name}_class = rb_const_get(godot_module, rb_intern("#{name}"));
          VALUE obj = rb_funcall(#{c_name}_class, rb_intern("allocate"), 0);
          godot_#{c_name} copy;
          api->godot_#{c_name}_new_copy(&copy, addr);
          return rb_iv_set(obj, "@_godot_address", LONG2NUM((long)&copy));
        }
      EOF
    end

    def to_godot_function
      <<~EOF
        godot_#{c_name} *rb_godot_#{c_name}_to_godot (VALUE self) {
          VALUE addr = rb_iv_get(self, "@_godot_address");
          return (godot_#{c_name}*)NUM2LONG(addr);
        }
      EOF
    end

    def initialize_method
      <<~EOF
        def initialize arg
          if arg.is_a?(#{type_checker})
            _initialize(arg)
          else
            raise "mismatched arguments"
          end
        end
      EOF
    end

    def register_method_statements
      initializers = "rb_define_method(string_class, \"_initialize\", &rb_godot_#{c_name}_initialize, 1);"
      <<~EOF
        VALUE #{c_name}_class = rb_const_get(godot_module, rb_intern("#{name}"));
        #{initializers}
        rb_define_method(#{c_name}_class, "finalize", &rb_godot_#{c_name}_finalize, 0);
      EOF
    end

    def class_definition
      <<~EOF
        module Godot
          class #{name} < Godot::BuiltInType
            #{initialize_method}

            def _type
              #{type_id}
            end
          end
        end
      EOF
    end

    def functions
      [initializer_function, to_godot_function, from_godot_function, finalizer_function].flatten.join("\n")
    end
  end
end
