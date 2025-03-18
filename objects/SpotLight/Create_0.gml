event_inherited()
type = LightTypes.SPOT
nx = 1
ny = 0
nz = 0
range = 1
cutoff_inner = 0
cutoff_outer = 1

#region Virtual Functions
update_args = function (_nx, _ny, _nz, _range, _cutoff_inner, _cutoff_outer) {
	nx = _nx
	ny = _ny
	nz = _nz
	range = _range
	cutoff_inner = _cutoff_inner
	cutoff_outer = _cutoff_outer
	arg0 = _nx
	arg1 = _ny
	arg2 = _nz
	arg3 = _range
	arg4 = _cutoff_inner
	arg5 = _cutoff_outer
}
#endregion

#region Events
proLight_event_create = event_create

event_create = function () {
	if is_struct(special) {
		nx = force_type_fallback(special[$ "nx"], "number", 1)
		ny = force_type_fallback(special[$ "ny"], "number", 0)
		nz = force_type_fallback(special[$ "nz"], "number", 0)
		range = force_type_fallback(special[$ "range"], "number", 1)
		cutoff_inner = force_type_fallback(special[$ "cutoff_inner"], "number", 0)
		cutoff_outer = force_type_fallback(special[$ "cutoff_outer"], "number", 1)
	}
	
	arg0 = nx
	arg1 = ny
	arg2 = nz
	arg3 = range
	arg4 = cutoff_inner
	arg5 = cutoff_outer
	interp_skip("sarg0")
	interp_skip("sarg1")
	interp_skip("sarg2")
	interp_skip("sarg3")
	interp_skip("sarg4")
	interp_skip("sarg5")
	proLight_event_create()
}
#endregion