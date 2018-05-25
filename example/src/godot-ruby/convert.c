
extern const godot_gdnative_core_api_struct *api;

godot_variant gdrb_ruby_builtin_to_godot_variant(VALUE robject);

godot_variant gdrb_ruby_nil_to_godot_variant() {
	godot_variant gvar;
	api->godot_variant_new_nil(&gvar);
	return gvar;
}

godot_variant gdrb_ruby_true_to_godot_variant() {
	godot_variant gvar;
	api->godot_variant_new_bool(&gvar, 1);
	return gvar;
}

godot_variant gdrb_ruby_false_to_godot_variant() {
	godot_variant gvar;
	api->godot_variant_new_bool(&gvar, 0);
	return gvar;
}

godot_variant gdrb_ruby_fixnum_to_godot_variant(VALUE rfixnum) {
	godot_variant gvar;
	api->godot_variant_new_int(&gvar, FIX2LONG(rfixnum));
	return gvar;
}

godot_variant gdrb_ruby_string_to_godot_variant(VALUE rstring) {
	char* str = StringValuePtr(rstring);
	int len = RSTRING_LEN(rstring);

	godot_string gstr;
	godot_variant gvar;

	api->godot_string_new(&gstr);
	api->godot_string_parse_utf8_with_len(&gstr, str, len);
	api->godot_variant_new_string(&gvar, &gstr);
	api->godot_string_destroy(&gstr);

	return gvar;
}

godot_variant gdrb_ruby_float_to_godot_variant(VALUE rfloat) {
	godot_variant gvar;
	api->godot_variant_new_real(&gvar, RFLOAT_VALUE(rfloat));
	return gvar;
}

godot_variant gdrb_ruby_symbol_to_godot_variant(VALUE rsymbol) {
	return gdrb_ruby_string_to_godot_variant(rb_sym2str(rsymbol));
}

godot_variant gdrb_ruby_array_to_godot_variant(VALUE rarray) {
	godot_array gary;
	godot_variant gvar;
	api->godot_array_new(&gary);

	for (int i=0; i < RARRAY_LEN(rarray); ++i) {
		godot_variant ary_var = gdrb_ruby_builtin_to_godot_variant(RARRAY_AREF(rarray, i));
		api->godot_array_append(&gary, &ary_var);
		api->godot_variant_destroy(&ary_var);
	}

	api->godot_variant_new_array(&gvar, &gary);
	api->godot_array_destroy(&gary);
	return gvar;
}

godot_variant gdrb_ruby_hash_to_godot_variant(VALUE rhash) {
	godot_dictionary gdic;
	godot_variant gvar;

	api->godot_dictionary_new(&gdic);

	VALUE pairs = rb_funcall(rhash, rb_intern("to_a"), 0);

	for (int i=0; i < RARRAY_LEN(pairs); ++i) {
		godot_variant key, value;
		VALUE pair = RARRAY_AREF(pairs, i);
		key = gdrb_ruby_builtin_to_godot_variant(RARRAY_AREF(pair, 0));
		value = gdrb_ruby_builtin_to_godot_variant(RARRAY_AREF(pair, 1));
		api->godot_dictionary_set(&gdic, &key, &value);
		api->godot_variant_destroy(&key);
		api->godot_variant_destroy(&value);
	}

	api->godot_variant_new_dictionary(&gvar, &gdic);
	api->godot_dictionary_destroy(&gdic);
	return gvar;
}

godot_variant gdrb_ruby_builtin_to_godot_variant(VALUE robject) {
	switch (TYPE(robject)) {
		case T_NIL:
			return gdrb_ruby_nil_to_godot_variant();
		case T_TRUE:
			return gdrb_ruby_true_to_godot_variant();
		case T_FALSE:
			return gdrb_ruby_false_to_godot_variant();
		case T_FIXNUM:
			return gdrb_ruby_fixnum_to_godot_variant(robject);
		case T_STRING:
			return gdrb_ruby_string_to_godot_variant(robject);
		case T_FLOAT:
			return gdrb_ruby_float_to_godot_variant(robject);
		case T_SYMBOL:
			return gdrb_ruby_symbol_to_godot_variant(robject);
		case T_ARRAY:
			return gdrb_ruby_array_to_godot_variant(robject);
		case T_HASH:
			return gdrb_ruby_hash_to_godot_variant(robject);
		default:
			return gdrb_ruby_string_to_godot_variant(rb_funcall(robject, rb_intern("to_s"), 0));
	}
}

void gdrb_handle_ruby_exception() {
	VALUE exception = rb_errinfo();
	VALUE backtrace = rb_funcall(rb_funcall(exception, rb_intern("backtrace"), 0), rb_intern("to_s"), 0);
	VALUE klass = rb_funcall(rb_funcall(exception, rb_intern("class"), 0), rb_intern("name"), 0);
	api->godot_print_error(StringValueCStr(backtrace), StringValueCStr(klass), __FILE__, __LINE__);
	rb_set_errinfo(Qnil);
}

VALUE gdrb_godot_string_to_ruby_string(const godot_string *str) {
	VALUE ruby_str;
	godot_char_string char_string = api->godot_string_utf8(str);
	const char *chars = api->godot_char_string_get_data(&char_string);
	ruby_str = rb_str_new_cstr(chars);
	api->godot_char_string_destroy(&char_string);
	return ruby_str;
}

VALUE gdrb_godot_string_name_to_ruby_string(godot_string_name *str) {

}

ID gdrb_godot_string_name_to_ruby_symbol(godot_string *str) {

}
