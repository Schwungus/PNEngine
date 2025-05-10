/// @func lengthdir_3d(length, yaw, pitch)
/// @param {Real} length
/// @param {Real} yaw
/// @param {Real} pitch
/// @return {Array<Real>}
function lengthdir_3d(_len, _yaw, _pitch) {
	gml_pragma("forceinline")
	
	static result = array_create(3)
	
	var _nz = dcos(_pitch)
	
	result[0] = lengthdir_x(_len, _yaw) * _nz
	result[1] = lengthdir_y(_len, _yaw) * _nz
	result[2] = -lengthdir_y(_len, _pitch)
	
	return result
}