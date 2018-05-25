godot_variant gdrb_ruby_nil_to_godot_variant();

godot_variant gdrb_ruby_true_to_godot_variant();

godot_variant gdrb_ruby_false_to_godot_variant();

godot_variant gdrb_ruby_fixnum_to_godot_variant(VALUE rfixnum);

godot_variant gdrb_ruby_string_to_godot_variant(VALUE rstring);

godot_variant gdrb_ruby_float_to_godot_variant(VALUE rfloat);

godot_variant gdrb_ruby_symbol_to_godot_variant(VALUE rsymbol);

godot_variant gdrb_ruby_array_to_godot_variant(VALUE rarray);

godot_variant gdrb_ruby_hash_to_godot_variant(VALUE rhash);

godot_variant gdrb_ruby_builtin_to_godot_variant(VALUE robject);

void gdrb_handle_ruby_exception();

VALUE gdrb_godot_string_to_ruby_string(const godot_string *str);

VALUE gdrb_godot_string_name_to_ruby_string(godot_string_name *str);

ID gdrb_godot_string_name_to_ruby_symbol(godot_string *str);
