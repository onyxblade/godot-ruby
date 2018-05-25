
#define DEFINE_RB_GODOT_BUILT_IN_TO_GODOT(type) type *rb_##type##_to_godot (VALUE self) {\
													VALUE addr = rb_iv_get(self, "@_godot_address");\
													return (type*)NUM2LONG(addr);\
												}

#define REGISTER_RB_GODOT_METHODS(type, clas, argc) VALUE type##_class = rb_const_get(godot_module, rb_intern(#clas));\
													rb_define_singleton_method(type##_class, "from_godot", &rb_godot_##type##_from_godot, 1);\
													rb_define_method(type##_class, "initialize", &rb_godot_##type##_initialize, argc);\
													rb_define_method(type##_class, "finalize", &rb_godot_built_in_finalize, 0);

VALUE rb_godot_built_in_finalize (VALUE self) {
	VALUE addr = rb_iv_get(self, "@_godot_address");
	api->godot_free((void*)NUM2LONG(addr));
	return Qtrue;
}


VALUE rb_godot_vector2_initialize (VALUE self, VALUE x, VALUE y) {
	godot_vector2 *vec = api->godot_alloc(sizeof(godot_vector2));
	api->godot_vector2_new(vec, NUM2DBL(x), NUM2DBL(y));
	return rb_iv_set(self, "@_godot_address", LONG2NUM((long)vec));
}

VALUE rb_godot_vector2_from_godot (VALUE self, godot_vector2 *addr) {
	godot_real x = api->godot_vector2_get_x(addr);
	godot_real y = api->godot_vector2_get_y(addr);
	return rb_funcall(self, rb_intern("new"), 2, DBL2NUM(x), DBL2NUM(y));
}

DEFINE_RB_GODOT_BUILT_IN_TO_GODOT(godot_vector2);

VALUE rb_godot_vector3_initialize (VALUE self, VALUE x, VALUE y, VALUE z) {
	godot_vector3 *vec = api->godot_alloc(sizeof(godot_vector3));
	api->godot_vector3_new(vec, NUM2DBL(x), NUM2DBL(y), NUM2DBL(z));
	return rb_iv_set(self, "@_godot_address", LONG2NUM((long)vec));
}

VALUE rb_godot_vector3_from_godot (VALUE self, godot_vector3 *addr) {
	godot_real x = api->godot_vector3_get_axis(addr, GODOT_VECTOR3_AXIS_X);
	godot_real y = api->godot_vector3_get_axis(addr, GODOT_VECTOR3_AXIS_Y);
	godot_real z = api->godot_vector3_get_axis(addr, GODOT_VECTOR3_AXIS_Z);
	return rb_funcall(self, rb_intern("new"), 3, DBL2NUM(x), DBL2NUM(y), DBL2NUM(z));
}

DEFINE_RB_GODOT_BUILT_IN_TO_GODOT(godot_vector3);

void init() {
	VALUE godot_module = rb_const_get(rb_cModule, rb_intern("Godot"));

	REGISTER_RB_GODOT_METHODS(vector2, Vector2, 2);
	REGISTER_RB_GODOT_METHODS(vector3, Vector3, 3);
}
