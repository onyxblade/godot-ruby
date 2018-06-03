
const godot_gdnative_core_api_struct *api = NULL;
const godot_gdnative_ext_pluginscript_api_struct *pluginscript_api = NULL;

static const char *GDRB_RUBY_RECOGNIZED_EXTENSIONS[] = { "rb", 0 };
static const char *GDRB_RUBY_RESERVED_WORDS[] = {
	"__ENCODING__",
	"__LINE__",
	"__FILE__",
	"BEGIN",
	"END",
	"alias",
	"and",
	"begin",
	"break",
	"case",
	"class",
	"def",
	"defined?",
	"do",
	"else",
	"elsif",
	"end",
	"ensure",
	"false",
	"for",
	"if",
	"in",
	"module",
	"next",
	"nil",
	"not",
	"or",
	"redo",
	"rescue",
	"retry",
	"return",
	"self",
	"super",
	"then",
	"true",
	"undef",
	"unless",
	"until",
	"when",
	"while",
	"yield",
	0
};
static const char *GDRB_RUBY_COMMENT_DELIMITERS[] = { "#", 0 };
static const char *GDRB_RUBY_STRING_DELIMITERS[] = { "\" \"", "' '", 0 };
static godot_pluginscript_language_desc desc;

static VALUE rb_mGodot;

typedef struct {
	VALUE klass;
} gdrb_pluginscript_script_data;

typedef struct {
	VALUE object;
	godot_object *owner;
} gdrb_pluginscript_instance_data;

godot_string gdrb_get_template_source_code(godot_pluginscript_language_data *p_data, const godot_string *p_class_name, const godot_string *p_base_class_name) {
	// p_class_name is the filename
	VALUE template = rb_funcall(rb_mGodot, rb_intern("_template_source_code"), 1, rb_godot_string_pointer_from_godot(p_base_class_name));
	godot_string ret;
	api->godot_string_new_copy(&ret, rb_godot_string_pointer_to_godot(template));
	printf("get_template_source_code\n");
	return ret;
}
void gdrb_add_global_constant(godot_pluginscript_language_data *p_data, const godot_string *p_variable, const godot_variant *p_value) {
	printf("add_global_constant\n");
}

VALUE rb_godot_object_call(VALUE self, VALUE method_name, VALUE method_args) {
	godot_object *pointer = rb_godot_object_pointer_to_godot(self);
	godot_variant gv_args = rb_godot_variant_to_godot(method_args);
	godot_variant gv_name = rb_godot_variant_to_godot(method_name);

	godot_variant_call_error p_error;
	godot_method_bind *method_bind = api->godot_method_bind_get_method("Object", "callv");

	const godot_variant *c_args[] = {
		&gv_name,
		&gv_args
	};
	godot_variant ret =  api->godot_method_bind_call(method_bind, pointer, c_args, 2, &p_error);
	// printf("call error %d", p_error.error);
	return rb_godot_variant_from_godot(ret);
}

VALUE rb_godot_get_global_singleton (VALUE self, VALUE name) {
	godot_object* klass = api->godot_global_get_singleton(StringValueCStr(name));

	if (klass) {
		return rb_godot_object_pointer_from_godot(klass);
	} else {
		return Qnil;
	}
}

VALUE rb_godot_print (VALUE self, VALUE string) {
	api->godot_print(rb_godot_string_pointer_to_godot(string));
	return Qtrue;
}

VALUE rb_godot_print_error (VALUE self, VALUE exception) {
	VALUE message = rb_funcall(exception, rb_intern("message"), 0);
	VALUE backtrace = rb_funcall(rb_funcall(exception, rb_intern("backtrace"), 0), rb_intern("to_s"), 0);
	api->godot_print_error(StringValueCStr(message), StringValueCStr(backtrace), "ruby", 0);
	return Qtrue;
}

godot_pluginscript_language_data *gdrb_ruby_init() {
	printf("gdrb_ruby_init\n");
	ruby_init();
	ruby_script("godot");
	ruby_init_loadpath();
	VALUE load_path = rb_gv_get("$LOAD_PATH");
	rb_funcall(load_path, rb_intern("unshift"), 1, rb_str_new_cstr("/home/cichol/godot-ruby/lib"));
	rb_require("godot");
	rb_mGodot = rb_const_get(rb_cModule, rb_intern("Godot"));

	VALUE object_module = rb_const_get(rb_mGodot, rb_intern("Object"));
	rb_define_method(object_module, "_call", &rb_godot_object_call, 2);

	rb_define_singleton_method(rb_mGodot, "_get_singleton", &rb_godot_get_global_singleton, 1);
	rb_define_singleton_method(rb_mGodot, "_print", &rb_godot_print, 1);
	rb_define_singleton_method(rb_mGodot, "_print_error", &rb_godot_print_error, 1);
	init();

	rb_funcall(rb_mGodot, rb_intern("_initialize"), 0);

	return NULL;
}
void gdrb_ruby_finish(godot_pluginscript_language_data *p_data) {
	printf("ruby_finish\n");
	ruby_cleanup(0);
}

godot_pluginscript_script_manifest gdrb_ruby_script_init(godot_pluginscript_language_data *p_data, const godot_string *p_path, const godot_string *p_source, godot_error *r_error) {
	godot_pluginscript_script_manifest manifest;

	VALUE r_path = rb_godot_string_pointer_from_godot(p_path);
	VALUE r_source = rb_godot_string_pointer_from_godot(p_source);

	VALUE klass = rb_funcall(rb_mGodot, rb_intern("_register_class"), 2, rb_funcall(r_path, rb_intern("to_s"), 0), rb_funcall(r_source, rb_intern("to_s"), 0));

	gdrb_pluginscript_script_data *data;
	data = (gdrb_pluginscript_script_data*)api->godot_alloc(sizeof(gdrb_pluginscript_script_data));
	data->klass = klass;

	godot_string_name name;
	api->godot_string_name_new_data(&name, "anonymous");
	godot_string_name base;
	VALUE base_name = rb_funcall(klass, rb_intern("_base_name"), 0);
	api->godot_string_name_new_data(&base, StringValueCStr(base_name));

	godot_dictionary member_lines;
	api->godot_dictionary_new(&member_lines);

	godot_array methods;
	api->godot_array_new(&methods);

	VALUE method_hash = rb_eval_string("{name: 'test_a', args: [], default_args: [], return: {}, flags: 0, rpc_mode: 0}");
	godot_variant method_dict = rb_godot_variant_to_godot(method_hash);
	api->godot_array_append(&methods, &method_dict);
	api->godot_variant_destroy(&method_dict);

	godot_array signals;
	api->godot_array_new(&signals);

	VALUE property_hash = rb_eval_string("{name: 'text_a', type: 2, usage: 8199}");
	godot_variant property_dict = rb_godot_variant_to_godot(property_hash);
	godot_array properties;
	api->godot_array_new(&properties);
	api->godot_array_append(&properties, &property_dict);
	api->godot_variant_destroy(&property_dict);

	manifest.data = (godot_pluginscript_script_data*) data;
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
	gdrb_pluginscript_script_data *data = (gdrb_pluginscript_script_data*) p_data;
	rb_funcall(rb_mGodot, rb_intern("_unregister_class"), 1, data->klass);
	api->godot_free(p_data);
	printf("script_finish\n");
}

godot_pluginscript_instance_data *gdrb_ruby_instance_init(godot_pluginscript_script_data *p_data, godot_object *p_owner) {
	gdrb_pluginscript_script_data *script_data = (gdrb_pluginscript_script_data*) p_data;
	gdrb_pluginscript_instance_data *data;
	data = (gdrb_pluginscript_instance_data*)api->godot_alloc(sizeof(gdrb_pluginscript_instance_data));

	VALUE instance = rb_funcall(script_data->klass, rb_intern("new"), 0);

	data->object = instance;
	data->owner = p_owner;
	rb_iv_set(instance, "@_godot_address", LONG2NUM((long)p_owner));

	printf("ruby_instance_init\n");
	return (godot_pluginscript_instance_data*)data;
}

void gdrb_ruby_instance_finish(godot_pluginscript_instance_data *p_data) {
	gdrb_pluginscript_instance_data *data = (gdrb_pluginscript_instance_data *) p_data;
	rb_funcall(rb_mGodot, rb_intern("_unregister_object"), 1, data->object);
	api->godot_free(p_data);
	printf("instance_finish\n");
}

godot_bool gdrb_ruby_instance_set_prop(godot_pluginscript_instance_data *p_data, const godot_string *p_name, const godot_variant *p_value) {
	gdrb_pluginscript_instance_data *data = (gdrb_pluginscript_instance_data*) p_data;
	printf("instance_set_prop\n");
	VALUE method_name = rb_funcall(rb_funcall(rb_godot_string_pointer_from_godot(p_name), rb_intern("to_s"), 0), rb_intern("concat"), 1, rb_str_new_cstr("="));

	if (RTEST(rb_funcall(data->object, rb_intern("respond_to?"), 1, method_name))) {
		rb_funcall(data->object, rb_intern_str(method_name), 1, rb_godot_variant_from_godot(*p_value));
		return 1;
	} else {
		return 0;
	}
}
godot_bool gdrb_ruby_instance_get_prop(godot_pluginscript_instance_data *p_data, const godot_string *p_name, godot_variant *r_ret) {
	gdrb_pluginscript_instance_data *data = (gdrb_pluginscript_instance_data*) p_data;
	printf("instance_get_prop\n");
	VALUE method_name = rb_funcall(rb_godot_string_pointer_from_godot(p_name), rb_intern("to_s"), 0);

	if (RTEST(rb_funcall(data->object, rb_intern("respond_to?"), 1, method_name))) {
		godot_variant var;
		VALUE ret = rb_funcall(data->object, rb_intern_str(method_name), 0);
		var = rb_godot_variant_to_godot(ret);
		memcpy(r_ret, &var, sizeof(godot_variant));
		return 1;
	} else {
		return 0;
	}
}

godot_variant gdrb_ruby_instance_call_method(godot_pluginscript_instance_data *p_data, const godot_string_name *p_method, const godot_variant **p_args, int p_argcount, godot_variant_call_error *r_error) {
	printf("instance_call_method\n");
	gdrb_pluginscript_instance_data *data = (gdrb_pluginscript_instance_data*) p_data;

	godot_string method_name = api->godot_string_name_get_name(p_method);
	VALUE method_name_str = rb_funcall(rb_godot_string_pointer_from_godot(&method_name), rb_intern("to_s"), 0);
	VALUE respond_to = rb_funcall(data->object, rb_intern("respond_to?"), 1, rb_funcall(method_name_str, rb_intern("to_s"), 0));

	godot_variant var;

	if (RTEST(respond_to)) {
		VALUE arguments[p_argcount+2];
		arguments[0] = data->object;
		arguments[1] = method_name_str;

		for (int i=0; i < p_argcount; ++i) {
			arguments[i + 2] = rb_godot_variant_from_godot(*p_args[i]);
		}

		VALUE ret = rb_funcallv(rb_mGodot, rb_intern("call_method"), p_argcount + 2, arguments);

		var = rb_godot_variant_to_godot(ret);
	} else {
		VALUE klass = rb_funcall(data->object, rb_intern("class"), 0);
		VALUE base_name = rb_funcall(klass, rb_intern("_base_name"), 0);

		godot_method_bind *method;
		wchar_t *wchars = api->godot_string_wide_str(&method_name);
		{
			int len = api->godot_string_length(&method_name);
			char chars[len+1];
			wcstombs(chars, wchars, len + 1);

			method = api->godot_method_bind_get_method(StringValueCStr(base_name), chars);

			if (method) {
				var = api->godot_method_bind_call(method, data->owner, p_args, p_argcount, r_error);
			} else {
				api->godot_variant_new_nil(&var);
				r_error->error = GODOT_CALL_ERROR_CALL_ERROR_INVALID_METHOD;
			}
		}
	}

	api->godot_string_destroy(&method_name);
	return var;
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
	desc.add_global_constant = &gdrb_add_global_constant;

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
		desc.get_template_source_code = &gdrb_get_template_source_code;
/*
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
	api = NULL;
	pluginscript_api = NULL;
}

void GDN_EXPORT godot_gdnative_singleton() {
}

