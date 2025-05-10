/// @func normal_vector_3d(yaw, pitch)
/// @param {Real} yaw
/// @param {Real} pitch
/// @return {Array<Real>}
function normal_vector_3d(_yaw, _pitch) {
	gml_pragma("forceinline")
	
	static result = array_create(3)
	
	var _nz = dcos(_pitch)
	
	result[0] = dcos(_yaw) * _nz
	result[1] = -dsin(_yaw) * _nz
	result[2] = dsin(_pitch)
	
	return result
}