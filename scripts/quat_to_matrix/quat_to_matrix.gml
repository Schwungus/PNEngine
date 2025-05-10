/// @func quat_to_matrix(q, [matrix])
/// @param {Array<Real>} q
/// @param {Array<Real>} [matrix]
/// @return {Array<Real>}
function quat_to_matrix(_q, _matrix = matrix_build_identity()) {
	var _x = _q[0]
	var _y = _q[1]
	var _z = _q[2]
	var _w = _q[3]
	
	// Build matrix
	_matrix[0] = 2 * (_w * _w + _x * _x) - 1
	_matrix[1] = 2 * (_x * _y - _w * _z)
	_matrix[2] = 2 * (_x * _z + _w * _y)
	_matrix[3] = 0
	_matrix[4] = 2 * (_x * _y + _w * _z)
	_matrix[5] = 2 * (_w * _w + _y * _y) - 1
	_matrix[6] = 2 * (_y * _z - _w * _x)
	_matrix[7] = 0
	_matrix[8] = 2 * (_x * _z - _w * _y)
	_matrix[9] = 2 * (_y * _z + _w * _x)
	_matrix[10] = 2 * (_w * _w + _z * _z) - 1
	_matrix[11] = 0
	_matrix[12] = 0
	_matrix[13] = 0
	_matrix[14] = 0
	_matrix[15] = 1
	
	return _matrix
}