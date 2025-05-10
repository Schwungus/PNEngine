/// @func matrix_build_fromto(x, y, z, to_x, to_y, to_z, up_x, up_y, up_z, x_scale, y_scale, z_scale, [matrix])
/// @param {Real} x
/// @param {Real} y
/// @param {Real} z
/// @param {Real} to_x
/// @param {Real} to_y
/// @param {Real} to_z
/// @param {Real} up_x
/// @param {Real} up_y
/// @param {Real} up_z
/// @param {Real} x_scale
/// @param {Real} y_scale
/// @param {Real} z_scale
/// @param {Array<Real>} [matrix]
/// @return {Array<Real>}
function matrix_build_fromto(_x, _y, _z, _to_x, _to_y, _to_z, _up_x, _up_y, _up_z, _x_scale, _y_scale, _z_scale, _matrix = matrix_build_identity()) {
	// Creates a 4x4 matrix with the to-direction as master
	var l = 1 / sqrt(_to_x * _to_x + _to_y * _to_y + _to_z * _to_z)
	
	_to_x *= l
	_to_y *= l
	_to_z *= l
	
	// Orthogonalize up-vector to to-vector
	var _dot = _up_x * _to_x + _up_y * _to_y + _up_z * _to_z
	
	_up_x -= _to_x * _dot
	_up_y -= _to_y * _dot
	_up_z -= _to_z * _dot
	
	// Normalize up-vector
	l = 1 / sqrt(_up_x * _up_x + _up_y * _up_y + _up_z * _up_z)
	_up_x *= l
	_up_y *= l
	_up_z *= l
	
	// Create side vector
	var _si_x = _up_y * _to_z - _up_z * _to_y
	var _si_y = _up_z * _to_x - _up_x * _to_z
	var _si_z = _up_x * _to_y - _up_y * _to_x
	
	// Return a 4x4 matrix
	_matrix[0] = _to_x * _x_scale
	_matrix[1] = _to_y * _x_scale
	_matrix[2] = _to_z * _x_scale
	_matrix[3] = 0
	_matrix[4] = _si_x * _y_scale
	_matrix[5] = _si_y * _y_scale
	_matrix[6] = _si_z * _y_scale
	_matrix[7] = 0
	_matrix[8] = _x
	_matrix[9] = _y
	_matrix[10] = _z
	_matrix[11] = 1
	
	return _matrix
}