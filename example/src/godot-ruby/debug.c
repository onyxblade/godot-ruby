void print_godot_string(const godot_string *str) {
	printf("%ls\n", api->godot_string_wide_str(str));
}

void print_godot_string_name(const godot_string_name *strname) {
	godot_string str = api->godot_string_name_get_name(strname);
	print_godot_string(&str);
	api->godot_string_destroy(&str);
}

void ruby_p(const VALUE value) {
	rb_funcall(rb_cObject, rb_intern("p"), 1, value);
}
