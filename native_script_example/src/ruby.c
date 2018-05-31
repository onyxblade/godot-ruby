#include <gdnative_api_struct.gen.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ruby.h>

typedef struct user_data_struct {
	char data[256];
} user_data_struct;

const godot_gdnative_core_api_struct *api = NULL;
const godot_gdnative_ext_nativescript_api_struct *nativescript_api = NULL;

GDCALLINGCONV void *gdrb_constructor(godot_object *p_instance, void *p_method_data);
GDCALLINGCONV void gdrb_destructor(godot_object *p_instance, void *p_method_data, void *p_user_data);
godot_variant gdrb_eval(godot_object *p_instance, void *p_method_data, void *p_user_data, int p_num_args, godot_variant **p_args);

void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options *p_options) {
	ruby_init();

	api = p_options->api_struct;

	// now find our extensions
	for (int i = 0; i < api->num_extensions; i++) {
		switch (api->extensions[i]->type) {
			case GDNATIVE_EXT_NATIVESCRIPT: {
				nativescript_api = (godot_gdnative_ext_nativescript_api_struct *)api->extensions[i];
			}; break;
			default: break;
		};
	};
}

void GDN_EXPORT godot_gdnative_terminate(godot_gdnative_terminate_options *p_options) {
	ruby_cleanup(0);
	api = NULL;
	nativescript_api = NULL;
}

void GDN_EXPORT godot_nativescript_init(void *p_handle) {
	godot_instance_create_func create = { NULL, NULL, NULL };
	create.create_func = &gdrb_constructor;

	godot_instance_destroy_func destroy = { NULL, NULL, NULL };
	destroy.destroy_func = &gdrb_destructor;

	nativescript_api->godot_nativescript_register_class(p_handle, "Ruby", "Reference", create, destroy);

	godot_instance_method eval = { NULL, NULL, NULL };
	eval.method = &gdrb_eval;

	godot_method_attributes attributes = { GODOT_METHOD_RPC_MODE_DISABLED };

	nativescript_api->godot_nativescript_register_method(p_handle, "Ruby", "eval", attributes, eval);
}

GDCALLINGCONV void *gdrb_constructor(godot_object *p_instance, void *p_method_data) {
	return NULL;
}

GDCALLINGCONV void gdrb_destructor(godot_object *p_instance, void *p_method_data, void *p_user_data) {
}

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
		godot_variant ary_var = rb_godot_variant_to_godot(RARRAY_AREF(rarray, i));
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
		key = rb_godot_variant_to_godot(RARRAY_AREF(pair, 0));
		value = rb_godot_variant_to_godot(RARRAY_AREF(pair, 1));
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

godot_variant gdrb_eval(godot_object *p_instance, void *p_method_data, void *p_user_data, int p_num_args, godot_variant **p_args) {
	godot_string command_string = api->godot_variant_as_string(p_args[0]);
	godot_char_string command_char_string = api->godot_string_utf8(&command_string);
	char* command = api->godot_char_string_get_data(&command_char_string);

	int state;
	VALUE result;
	result = rb_eval_string_protect(command, &state);
	api->godot_char_string_destroy(&command_char_string);
	if (state) {
		gdrb_handle_ruby_exception();
	}
	return gdrb_ruby_builtin_to_godot_variant(result);
}
