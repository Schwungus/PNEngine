event_inherited()
type = LightTypes.POINT
near = 0
far = 0

#region Virtual Functions
/// @func update_args(near, far)
/// @param {Real} near
/// @param {Real} far
/// @context PointLight
update_args = function (_near, _far) {
	near = _near
	far = _far
	arg0 = _near
	arg1 = _far
}
#endregion

#region Events
proLight_event_create = event_create

event_create = function () {
	if is_struct(special) {
		near = force_type_fallback(special[$ "near"], "number", 0)
		far = force_type_fallback(special[$ "far"], "number", 1)
	}
	
	arg0 = near
	arg1 = far
	interp_skip("sarg0")
	interp_skip("sarg1")
	proLight_event_create()
}
#endregion