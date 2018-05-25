
#define DEFINE_RB_GODOT_BUILT_IN_TO_GODOT(type) godot_##type *rb_godot_##type##_to_godot (VALUE self) {\
													VALUE addr = rb_iv_get(self, "@_godot_address");\
													return (godot_##type*)NUM2LONG(addr);\
												}

#define REGISTER_RB_GODOT_METHODS(type, clas, argc) VALUE type##_class = rb_const_get(godot_module, rb_intern(#clas));\
													rb_define_method(type##_class, "initialize_default", &rb_godot_##type##_initialize, argc);\
													rb_define_method(type##_class, "finalize", &rb_godot_built_in_finalize, 0);

#define GET_RB_GODOT_CLASS(type, class) VALUE godot_module = rb_const_get(rb_cModule, rb_intern("Godot"));\
										VALUE type##_class = rb_const_get(godot_module, rb_intern(#class))

#define ALLOC_RB_GODOT_BUILT_IN(type) godot_##type *addr = api->godot_alloc(sizeof(godot_##type));

#define SET_IV_FOR_RB_GODOT_BUILT_IN(type) return rb_iv_set(self, "@_godot_address", LONG2NUM((long)addr));

VALUE rb_godot_built_in_finalize (VALUE self) {
	VALUE addr = rb_iv_get(self, "@_godot_address");
	api->godot_free((void*)NUM2LONG(addr));
	return Qtrue;
}


VALUE rb_godot_vector2_initialize (VALUE self, VALUE x, VALUE y) {
	ALLOC_RB_GODOT_BUILT_IN(vector2);
	api->godot_vector2_new(addr, NUM2DBL(x), NUM2DBL(y));
	SET_IV_FOR_RB_GODOT_BUILT_IN(vector2);
}
VALUE rb_godot_vector2_from_godot (godot_vector2 *addr) {
	GET_RB_GODOT_CLASS(vector2, Vector2);
	godot_real x = api->godot_vector2_get_x(addr);
	godot_real y = api->godot_vector2_get_y(addr);
	return rb_funcall(vector2_class, rb_intern("new"), 2, DBL2NUM(x), DBL2NUM(y));
}
DEFINE_RB_GODOT_BUILT_IN_TO_GODOT(vector2);

VALUE rb_godot_vector3_initialize (VALUE self, VALUE x, VALUE y, VALUE z) {
	ALLOC_RB_GODOT_BUILT_IN(vector3);
	api->godot_vector3_new(addr, NUM2DBL(x), NUM2DBL(y), NUM2DBL(z));
	SET_IV_FOR_RB_GODOT_BUILT_IN(vector3);
}
VALUE rb_godot_vector3_from_godot (godot_vector3 *addr) {
	GET_RB_GODOT_CLASS(vector3, Vector3);
	godot_real x = api->godot_vector3_get_axis(addr, GODOT_VECTOR3_AXIS_X);
	godot_real y = api->godot_vector3_get_axis(addr, GODOT_VECTOR3_AXIS_Y);
	godot_real z = api->godot_vector3_get_axis(addr, GODOT_VECTOR3_AXIS_Z);
	return rb_funcall(vector3_class, rb_intern("new"), 3, DBL2NUM(x), DBL2NUM(y), DBL2NUM(z));
}
DEFINE_RB_GODOT_BUILT_IN_TO_GODOT(vector3);

VALUE rb_godot_aabb_initialize (VALUE self, VALUE pos, VALUE size) {
	ALLOC_RB_GODOT_BUILT_IN(aabb);
	api->godot_aabb_new(addr, rb_godot_vector3_to_godot(pos), rb_godot_vector3_to_godot(size));
	SET_IV_FOR_RB_GODOT_BUILT_IN(aabb);
}
VALUE rb_godot_aabb_from_godot (godot_aabb *addr) {
	GET_RB_GODOT_CLASS(aabb, Aabb);
	godot_vector3 position = api->godot_aabb_get_position(addr);
	godot_vector3 size = api->godot_aabb_get_size(addr);
	return rb_funcall(aabb_class, rb_intern("new"), 2, rb_godot_vector3_from_godot(&position), rb_godot_vector3_from_godot(&size));
}
DEFINE_RB_GODOT_BUILT_IN_TO_GODOT(aabb);

VALUE rb_godot_quat_initialize (VALUE self, VALUE x, VALUE y, VALUE z, VALUE w) {
	ALLOC_RB_GODOT_BUILT_IN(quat);
	api->godot_quat_new(addr, NUM2DBL(x), NUM2DBL(y), NUM2DBL(z), NUM2DBL(w));
	SET_IV_FOR_RB_GODOT_BUILT_IN(quat);
}
VALUE rb_godot_quat_initialize_with_axis_angle (VALUE self, VALUE axis, VALUE angle) {
	ALLOC_RB_GODOT_BUILT_IN(quat);
	api->godot_quat_new_with_axis_angle(addr, rb_godot_vector3_to_godot(axis), NUM2DBL(angle));
	SET_IV_FOR_RB_GODOT_BUILT_IN(quat);
}
VALUE rb_godot_quat_from_godot (godot_quat *addr) {
	GET_RB_GODOT_CLASS(quat, Quat);
	godot_real x = api->godot_quat_get_x(addr);
	godot_real y = api->godot_quat_get_y(addr);
	godot_real z = api->godot_quat_get_z(addr);
	godot_real w = api->godot_quat_get_w(addr);
	return rb_funcall(quat_class, rb_intern("new"), 4, DBL2NUM(x), DBL2NUM(y), DBL2NUM(z), DBL2NUM(w));
}
DEFINE_RB_GODOT_BUILT_IN_TO_GODOT(quat);

VALUE rb_godot_basis_initialize_with_rows (VALUE self, VALUE x_axis, VALUE y_axis, VALUE z_axis) {
	ALLOC_RB_GODOT_BUILT_IN(basis);
	api->godot_basis_new_with_rows(addr, rb_godot_vector3_to_godot(x_axis), rb_godot_vector3_to_godot(y_axis), rb_godot_vector3_to_godot(z_axis));
	SET_IV_FOR_RB_GODOT_BUILT_IN(basis);
}
VALUE rb_godot_basis_initialize_with_axis_and_angle (VALUE self, VALUE axis, VALUE phi) {
	ALLOC_RB_GODOT_BUILT_IN(basis);
	api->godot_basis_new_with_axis_and_angle(addr, rb_godot_vector3_to_godot(axis), NUM2DBL(phi));
	SET_IV_FOR_RB_GODOT_BUILT_IN(basis);
}
VALUE rb_godot_basis_initialize_with_euler (VALUE self, VALUE euler) {
	ALLOC_RB_GODOT_BUILT_IN(basis);
	api->godot_basis_new_with_euler(addr, rb_godot_vector3_to_godot(euler));
	SET_IV_FOR_RB_GODOT_BUILT_IN(basis);
}
VALUE rb_godot_basis_initialize_with_euler_quat (VALUE self, VALUE euler) {
	ALLOC_RB_GODOT_BUILT_IN(basis);
	api->godot_basis_new_with_euler_quat(addr, rb_godot_quat_to_godot(euler));
	SET_IV_FOR_RB_GODOT_BUILT_IN(basis);
}
VALUE rb_godot_basis_from_godot (godot_basis *addr) {
	GET_RB_GODOT_CLASS(basis, Basis);
	godot_vector3 euler = api->godot_basis_get_euler(addr);
	return rb_funcall(basis_class, rb_intern("new"), 1, rb_godot_vector3_from_godot(&euler));
}
DEFINE_RB_GODOT_BUILT_IN_TO_GODOT(basis);

void init() {
	VALUE godot_module = rb_const_get(rb_cModule, rb_intern("Godot"));

	REGISTER_RB_GODOT_METHODS(vector2, Vector2, 2);
	REGISTER_RB_GODOT_METHODS(vector3, Vector3, 3);
	REGISTER_RB_GODOT_METHODS(aabb, Aabb, 2);
	REGISTER_RB_GODOT_METHODS(quat, Quat, 4);
	rb_define_method(quat_class, "initialize_with_axis_angle", &rb_godot_quat_initialize_with_axis_angle, 2);
	VALUE basis_class = rb_const_get(godot_module, rb_intern("Basis"));
	rb_define_method(basis_class, "initialize_with_rows", &rb_godot_basis_initialize_with_rows, 3);
	rb_define_method(basis_class, "initialize_with_with_axis_and_angle", &rb_godot_basis_initialize_with_axis_and_angle, 2);
	rb_define_method(basis_class, "initialize_with_euler", &rb_godot_basis_initialize_with_euler, 1);
	rb_define_method(basis_class, "initialize_with_euler_quat", &rb_godot_basis_initialize_with_euler_quat, 1);
	rb_define_method(basis_class, "finalize", &rb_godot_built_in_finalize, 0);

}
