
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

typedef struct {
	VALUE klass;
	VALUE links;
} gdrb_pluginscript_script_data;

typedef struct {
	VALUE object;
	godot_object *owner;
} gdrb_pluginscript_instance_data;

godot_string gdrb_get_template_source_code(godot_pluginscript_language_data *p_data, const godot_string *p_class_name, const godot_string *p_base_class_name) {
	// p_class_name is the filename
	godot_string prefix, mid, postfix, template;
	api->godot_string_new(&prefix);
	api->godot_string_new(&mid);
	api->godot_string_new(&postfix);
	api->godot_string_parse_utf8(&prefix, "class ");
	api->godot_string_parse_utf8(&mid, " < Godot::");
	api->godot_string_parse_utf8(&postfix, "\n\nend");
	// will plus leak?
	template = api->godot_string_operator_plus(&prefix, p_class_name);
	template = api->godot_string_operator_plus(&template, &mid);
	template = api->godot_string_operator_plus(&template, p_base_class_name);
	template = api->godot_string_operator_plus(&template, &postfix);
	api->godot_string_destroy(&prefix);
	api->godot_string_destroy(&mid);
	api->godot_string_destroy(&postfix);
	printf("get_template_source_code\n");
	return template;
}
void gdrb_add_global_constant(godot_pluginscript_language_data *p_data, const godot_string *p_variable, const godot_variant *p_value) {
	printf("add_global_constant\n");
}

VALUE gdrb_object_call(VALUE self, VALUE method_name, VALUE method_args) {
	VALUE rpointer = rb_funcall(self, rb_intern("godot_pointer"), 0);
	godot_object *pointer = (godot_object *)NUM2LONG(rpointer);
	godot_variant gv_args = rb_godot_variant_to_godot(method_args);
	godot_variant gv_name = rb_godot_variant_to_godot(method_name);

	godot_variant_call_error p_error;
	godot_method_bind *method_bind = api->godot_method_bind_get_method("Object", "callv");

	const godot_variant *c_args[] = {
		&gv_name,
		&gv_args
	};
	api->godot_method_bind_call(method_bind, pointer, c_args, 2, &p_error);
	printf("call error %d", p_error.error);
	return Qnil;
}

godot_pluginscript_language_data *gdrb_ruby_init() {
	printf("gdrb_ruby_init\n");
	ruby_init();
	ruby_script("godot");
	ruby_init_loadpath();
	VALUE load_path = rb_gv_get("$LOAD_PATH");
	rb_funcall(load_path, rb_intern("unshift"), 1, rb_str_new_cstr("/home/cichol/godot-ruby/lib"));
	rb_require("godot");
	VALUE godot_module = rb_const_get(rb_cModule, rb_intern("Godot"));
	rb_define_const(godot_module, "ROOT", rb_str_new_cstr("/home/cichol/godot-ruby/example"));

	VALUE object_module = rb_const_get(godot_module, rb_intern("Object"));
	rb_define_method(object_module, "call_native", &gdrb_object_call, 2);
	init();
	return NULL;
}
void gdrb_ruby_finish(godot_pluginscript_language_data *p_data) {
	printf("ruby_finish\n");
	ruby_cleanup(0);
}

godot_pluginscript_script_manifest gdrb_ruby_script_init(godot_pluginscript_language_data *p_data, const godot_string *p_path, const godot_string *p_source, godot_error *r_error) {
	godot_pluginscript_script_manifest manifest;

	VALUE godot_module = rb_const_get(rb_cModule, rb_intern("Godot"));
	VALUE r_path = rb_godot_string_pointer_from_godot(p_path);

	VALUE klass = rb_funcall(godot_module, rb_intern("require_script"), 1, rb_funcall(r_path, rb_intern("to_s"), 0));

	gdrb_pluginscript_script_data *data;
	data = (gdrb_pluginscript_script_data*)malloc(sizeof(gdrb_pluginscript_script_data));
	data->klass = klass;

	data->links = rb_const_get(godot_module, rb_intern("LINKS"));
	VALUE klass_name = rb_funcall(klass, rb_intern("name"), 0);
	godot_string_name name;
	api->godot_string_name_new_data(&name, StringValueCStr(klass_name));
	godot_string_name base;
	VALUE base_name_symbol = rb_funcall(klass, rb_intern("base_name"), 0);
	VALUE base_name = rb_funcall(base_name_symbol, rb_intern("to_s"), 0);
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

	godot_array properties;
	api->godot_array_new(&properties);

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
	free(p_data);
	printf("script_finish\n");
}

godot_pluginscript_instance_data *gdrb_ruby_instance_init(godot_pluginscript_script_data *p_data, godot_object *p_owner) {
	gdrb_pluginscript_script_data *script_data = (gdrb_pluginscript_script_data*) p_data;
	gdrb_pluginscript_instance_data *data;
	data = (gdrb_pluginscript_instance_data*)malloc(sizeof(gdrb_pluginscript_instance_data));

	VALUE instance = rb_funcall(script_data->klass, rb_intern("new"), 0);
	VALUE object_id = rb_funcall(instance, rb_intern("object_id"), 0);
	rb_funcall(script_data->links, rb_intern("[]="), 2, object_id, instance);
	data->object = instance;
	data->owner = p_owner;
	rb_funcall(instance, rb_intern("godot_pointer="), 1, LONG2NUM((long)p_owner));

	printf("ruby_instance_init\n");
	return (godot_pluginscript_instance_data*)data;
}

void gdrb_ruby_instance_finish(godot_pluginscript_instance_data *p_data) {
	free((gdrb_pluginscript_instance_data*)p_data);
	printf("instance_finish\n");
}

godot_bool gdrb_ruby_instance_set_prop(godot_pluginscript_instance_data *p_data, const godot_string *p_name, const godot_variant *p_value) {
	gdrb_pluginscript_instance_data *data = (gdrb_pluginscript_instance_data*) p_data;
	printf("instance_set_prop\n");
}
godot_bool gdrb_ruby_instance_get_prop(godot_pluginscript_instance_data *p_data, const godot_string *p_name, godot_variant *r_ret) {
	gdrb_pluginscript_instance_data *data = (gdrb_pluginscript_instance_data*) p_data;
	printf("instance_get_prop\n");
}

godot_variant gdrb_ruby_instance_call_method(godot_pluginscript_instance_data *p_data, const godot_string_name *p_method, const godot_variant **p_args, int p_argcount, godot_variant_call_error *r_error) {
	printf("instance_call_method\n");
	gdrb_pluginscript_instance_data *data = (gdrb_pluginscript_instance_data*) p_data;

	godot_string method_name = api->godot_string_name_get_name(p_method);
	VALUE method_name_str = rb_funcall(rb_godot_string_pointer_from_godot(&method_name), rb_intern("to_s"), 0);
	VALUE respond_to = rb_funcall(data->object, rb_intern("respond_to?"), 1, rb_funcall(method_name_str, rb_intern("to_s"), 0));

	godot_variant var;

	if (RTEST(respond_to)) {
		VALUE godot_module = rb_const_get(rb_cModule, rb_intern("Godot"));
		VALUE ret = rb_funcall(godot_module, rb_intern("call_method"), 2, data->object, method_name_str);

		var = rb_godot_variant_to_godot(ret);
	} else {
		VALUE klass = rb_funcall(data->object, rb_intern("class"), 0);
		VALUE base_name_symbol = rb_funcall(klass, rb_intern("base_name"), 0);
		VALUE base_name = rb_funcall(base_name_symbol, rb_intern("to_s"), 0);

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
				printf("called undefined method %ls\n", wchars);
			}
			printf("call error %d\n", r_error->error);
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

