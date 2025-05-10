/// @func unit_vector_3d(x, y, z)
/// @param {Real} x
/// @param {Real} y
/// @param {Real} z
/// @return {Array<Real>}
function unit_vector_3d(_x, _y, _z) {
	gml_pragma("forceinline")
	
	static result = array_create(3)
	
	var _inv = 1 / point_distance_3d(0, 0, 0, _x, _y, _z)
	
	result[0] = _x * _inv
	result[1] = _y * _inv
	result[2] = _z * _inv
	
	return result
}