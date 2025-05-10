event_inherited()
type = LightTypes.DIRECTIONAL
active = 1
nx = 0
ny = 0
nz = -1

#region Virtual Functions
/// @func update_args(nx, ny, nz)
/// @param {Real} nx
/// @param {Real} ny
/// @param {Real} nz
/// @context DirectionalLight
update_args = function (_nx, _ny, _nz) {
	nx = _nx
	ny = _ny
	nz = _nz
	arg0 = _nx
	arg1 = _ny
	arg2 = _nz
}
#endregion

#region Events
proLight_event_create = event_create

event_create = function () {
	if is_struct(special) {
		nx = force_type_fallback(special[$ "nx"], "number", 0)
		ny = force_type_fallback(special[$ "ny"], "number", 0)
		nz = force_type_fallback(special[$ "nz"], "number", 1)
	}
	
	arg0 = nx
	arg1 = ny
	arg2 = nz
	interp_skip("sarg0")
	interp_skip("sarg1")
	interp_skip("sarg2")
	proLight_event_create()
}
#endregion