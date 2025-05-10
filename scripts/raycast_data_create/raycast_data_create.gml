/// @func raycast_data_create()
/// @desc Creates a raycast data array to use for output.
/// @return {Array<Any>}
function raycast_data_create() {
	gml_pragma("forceinline")
	
	var _ray = array_create(RaycastData.__SIZE)
	
	_ray[RaycastData.HIT] = false
	_ray[RaycastData.X] = 0
	_ray[RaycastData.Y] = 0
	_ray[RaycastData.Z] = 0
	_ray[RaycastData.NX] = 0
	_ray[RaycastData.NY] = 0
	_ray[RaycastData.NZ] = -1
	_ray[RaycastData.SURFACE] = 0
	_ray[RaycastData.TRIANGLE] = undefined
	_ray[RaycastData.THING] = noone
	
	return _ray
}