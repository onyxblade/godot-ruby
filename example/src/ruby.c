#include <gdnative_api_struct.gen.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ruby.h>

typedef struct user_data_struct {
	char data[256];
} user_data_struct;

const godot_gdnative_core_api_struct *api = NULL;
const godot_gdnative_ext_pluginscript_api_struct *pluginscript_api = NULL;

static const char *GDRB_RUBY_RECOGNIZED_EXTENSIONS[] = { "rb", 0 };
static const char *GDRB_RUBY_RESERVED_WORDS[] = {
	"class"
	"def",
	"end",
	"do",
	0
};
static const char *GDRB_RUBY_COMMENT_DELIMITERS[] = { "#", 0 };
static const char *GDRB_RUBY_STRING_DELIMITERS[] = { "\" \"", "' '", 0 };
static godot_pluginscript_language_desc desc;

void print_godot_string(const godot_string *str) {
	godot_char_string char_string = api->godot_string_utf8(str);
	char* command = api->godot_char_string_get_data(&char_string);
	printf("%s\n", command);
	api->godot_char_string_destroy(&char_string);
}

void print_godot_string_name(const godot_string_name *strname) {
	godot_string str = api->godot_string_name_get_name(strname);
	print_godot_string(&str);
	api->godot_string_destroy(&str);
}

godot_string gdrb_get_template_source_code(godot_pluginscript_language_data *p_data, const godot_string *p_class_name, const godot_string *p_base_class_name) {
	printf("get_template_source_code\n");
}
void grdb_add_global_constant(godot_pluginscript_language_data *p_data, const godot_string *p_variable, const godot_variant *p_value) {
	printf("add_global_constant\n");
}
godot_pluginscript_language_data *gdrb_ruby_init() {
	printf("gdrb_ruby_init\n");
	return NULL;
}
void gdrb_ruby_finish(godot_pluginscript_language_data *p_data) {
	printf("ruby_finish\n");
}

godot_pluginscript_script_manifest gdrb_ruby_script_init(godot_pluginscript_language_data *p_data, const godot_string *p_path, const godot_string *p_source, godot_error *r_error) {
	print_godot_string(p_path);
	print_godot_string(p_source);
	godot_pluginscript_script_manifest manifest;

	godot_string_name name;
	api->godot_string_name_new_data(&name, "hello");

	godot_string_name base;
	api->godot_string_name_new_data(&base, "Object");

	godot_dictionary member_lines;
	api->godot_dictionary_new(&member_lines);

	godot_array methods;
	api->godot_array_new(&methods);

	godot_array signals;
	api->godot_array_new(&signals);

	godot_array properties;
	api->godot_array_new(&properties);

	manifest.data = NULL;
	manifest.name = name;
	manifest.is_tool = false;
	manifest.base = base;
	manifest.member_lines = member_lines;
	manifest.methods = methods;
	manifest.signals = signals;
	manifest.properties = properties;

	printf("ruby_script_init\n");
	return manifest;
}
void gdrb_ruby_script_finish(godot_pluginscript_script_data *p_data) {
	printf("script_finish\n");
}

godot_pluginscript_instance_data *gdrb_ruby_instance_init(godot_pluginscript_script_data *p_data, godot_object *p_owner) {
	printf("ruby_instance_init\n");
}

void gdrb_ruby_instance_finish(godot_pluginscript_instance_data *p_data) {
	printf("instance_finish\n");
}

godot_bool gdrb_ruby_instance_set_prop(godot_pluginscript_instance_data *p_data, const godot_string *p_name, const godot_variant *p_value) {
	printf("instance_set_prop\n");
}
godot_bool gdrb_ruby_instance_get_prop(godot_pluginscript_instance_data *p_data, const godot_string *p_name, godot_variant *r_ret) {
	printf("instance_get_prop\n");
}

godot_variant gdrb_ruby_instance_call_method(godot_pluginscript_instance_data *p_data, const godot_string_name *p_method, const godot_variant **p_args, int p_argcount, godot_variant_call_error *r_error) {
	printf("instance_call_method\n");
	print_godot_string_name(p_method);
}

void gdrb_ruby_instance_notification(godot_pluginscript_instance_data *p_data, int p_notification) {
	printf("instance_notification\n");
}

godot_bool gdrb_validate(godot_pluginscript_language_data *p_data, const godot_string *p_script, int *r_line_error, int *r_col_error, godot_string *r_test_error, const godot_string *p_path, godot_pool_string_array *r_functions) {
	printf("validate\n");
}

int gdrb_find_function(godot_pluginscript_language_data *p_data, const godot_string *p_function, const godot_string *p_code) {
	printf("find_function\n");
}
godot_string gdrb_make_function(godot_pluginscript_language_data *p_data, const godot_string *p_class, const godot_string *p_name, const godot_pool_string_array *p_args) {
	printf("make_function\n");
}
godot_error gdrb_complete_code(godot_pluginscript_language_data *p_data, const godot_string *p_code, const godot_string *p_base_path, godot_object *p_owner, godot_array *r_options, godot_bool *r_force, godot_string *r_call_hint) {
	printf("complete_code\n");

}
void gdrb_auto_indent_code(godot_pluginscript_language_data *p_data, godot_string *p_code, int p_from_line, int p_to_line) {
	printf("auto_indent_code\n");
}
godot_string gdrb_debug_get_error(godot_pluginscript_language_data *p_data) {
	printf("debug_get_error\n");
}
int gdrb_debug_get_stack_level_count(godot_pluginscript_language_data *p_data) {
	printf("debug_get_stack_level_count\n");
}
int gdrb_debug_get_stack_level_line(godot_pluginscript_language_data *p_data, int p_level) {
	printf("debug_get_stack_level_line\n");
}
godot_string gdrb_debug_get_stack_level_function(godot_pluginscript_language_data *p_data, int p_level) {
	printf("debug_get_stack_level_function\n");
}
godot_string gdrb_debug_get_stack_level_source(godot_pluginscript_language_data *p_data, int p_level) {
	printf("debug_get_stack_level_source\n");
}
void gdrb_debug_get_stack_level_locals(godot_pluginscript_language_data *p_data, int p_level, godot_pool_string_array *p_locals, godot_array *p_values, int p_max_subitems, int p_max_depth) {
	printf("debug_get_stack_level_locals\n");
}
void gdrb_debug_get_stack_level_members(godot_pluginscript_language_data *p_data, int p_level, godot_pool_string_array *p_members, godot_array *p_values, int p_max_subitems, int p_max_depth) {
	printf("debug_get_stack_level_members\n");
}
void gdrb_debug_get_globals(godot_pluginscript_language_data *p_data, godot_pool_string_array *p_locals, godot_array *p_values, int p_max_subitems, int p_max_depth) {
	printf("debug_get_globals\n");
}
godot_string gdrb_debug_parse_stack_level_expression(godot_pluginscript_language_data *p_data, int p_level, const godot_string *p_expression, int p_max_subitems, int p_max_depth) {
	printf("debug_parse_stack_level_expression\n");
}
void gdrb_profiling_start(godot_pluginscript_language_data *p_data) {
	printf("profiling_start\n");
}
void gdrb_profiling_stop(godot_pluginscript_language_data *p_data) {
	printf("profiling_stop\n");
}
int gdrb_profiling_get_accumulated_data(godot_pluginscript_language_data *p_data, godot_pluginscript_profiling_data *r_info, int p_info_max) {
	printf("gdrb_profiling_get_accumulated_data\n");
}
int gdrb_profiling_get_frame_data(godot_pluginscript_language_data *p_data, godot_pluginscript_profiling_data *r_info, int p_info_max) {
	printf("gdrb_profiling_get_frame_data\n");
}
void gdrb_profiling_frame(godot_pluginscript_language_data *p_data) {
	printf("profiling_frame\n");
}

void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options *p_options) {
	printf("gdnative init\n");
	ruby_init();

	api = p_options->api_struct;

	// now find our extensions
	for (int i = 0; i < api->num_extensions; i++) {
		switch (api->extensions[i]->type) {
			case GDNATIVE_EXT_PLUGINSCRIPT:
				pluginscript_api = (godot_gdnative_ext_pluginscript_api_struct *)api->extensions[i];
				break;
			default: break;
		};
	};

	desc.name = "Ruby";
	desc.type = "Ruby";
	desc.extension = "rb";
	desc.recognized_extensions = GDRB_RUBY_RECOGNIZED_EXTENSIONS;
	desc.init = &gdrb_ruby_init;
	desc.finish = &gdrb_ruby_finish;
	desc.reserved_words = GDRB_RUBY_RESERVED_WORDS;
	desc.comment_delimiters = GDRB_RUBY_COMMENT_DELIMITERS;
	desc.string_delimiters = GDRB_RUBY_STRING_DELIMITERS;
	desc.has_named_classes = false;
	desc.get_template_source_code = &gdrb_get_template_source_code;
	desc.add_global_constant = &grdb_add_global_constant;

	desc.script_desc.init = &gdrb_ruby_script_init;
	desc.script_desc.finish = &gdrb_ruby_script_finish;

	desc.script_desc.instance_desc.init = &gdrb_ruby_instance_init;
	desc.script_desc.instance_desc.finish = &gdrb_ruby_instance_finish;
	desc.script_desc.instance_desc.set_prop = &gdrb_ruby_instance_set_prop;
	desc.script_desc.instance_desc.get_prop = &gdrb_ruby_instance_get_prop;
	desc.script_desc.instance_desc.call_method = &gdrb_ruby_instance_call_method;
	desc.script_desc.instance_desc.notification = &gdrb_ruby_instance_notification;
	desc.script_desc.instance_desc.refcount_incremented = NULL;
	desc.script_desc.instance_desc.refcount_decremented = NULL;

	if (p_options->in_editor) {
/*
		desc.get_template_source_code = &gdrb_get_template_source_code;
		desc.validate = &gdrb_validate;
		desc.find_function = &gdrb_find_function;
		desc.make_function = &gdrb_make_function;
		desc.complete_code = &gdrb_complete_code;
		desc.auto_indent_code = &gdrb_auto_indent_code;

		desc.debug_get_error = &gdrb_debug_get_error;
		desc.debug_get_stack_level_count = &gdrb_debug_get_stack_level_count;
		desc.debug_get_stack_level_line = &gdrb_debug_get_stack_level_line;
		desc.debug_get_stack_level_function = &gdrb_debug_get_stack_level_function;
		desc.debug_get_stack_level_source = &gdrb_debug_get_stack_level_source;
		desc.debug_get_stack_level_locals = &gdrb_debug_get_stack_level_locals;
		desc.debug_get_stack_level_members = &gdrb_debug_get_stack_level_members;
		desc.debug_get_globals = &gdrb_debug_get_globals;
		desc.debug_parse_stack_level_expression = &gdrb_debug_parse_stack_level_expression;

		desc.profiling_start = &gdrb_profiling_start;
		desc.profiling_stop = &gdrb_profiling_stop;
		desc.profiling_get_accumulated_data = &gdrb_profiling_get_accumulated_data;
		desc.profiling_get_frame_data = &gdrb_profiling_get_frame_data;
		desc.profiling_frame = &gdrb_profiling_frame;
*/
	}
	pluginscript_api->godot_pluginscript_register_language(&desc);
	printf("registered language\n");
}

void GDN_EXPORT godot_gdnative_terminate(godot_gdnative_terminate_options *p_options) {
	printf("gdnative_terminate\n");
	ruby_cleanup(0);
	api = NULL;
	pluginscript_api = NULL;
}

void GDN_EXPORT godot_gdnative_singleton() {
}

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
