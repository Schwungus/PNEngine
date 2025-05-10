/// @func dq_build_matrix(matrix, [dq])
/// @desc Creates a dual quaternion from a matrix.
/// @param {Array<Real>} matrix
/// @param {Array<Real>} [dq]
/// @return {Array<Real>}
function dq_build_matrix(_matrix, _dq = dq_build_identity()) {	
	// Source: http://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToQuaternion/
	var t = 1 + _matrix[0] + _matrix[5] + _matrix[10]
	var s, _inv
	
	if t > 0 {
		s = sqrt(t) * 2
		_inv = 1 / s
		_dq[0] = (_matrix[9] - _matrix[6]) * _inv
		_dq[1] = (_matrix[2] - _matrix[8]) * _inv
		_dq[2] = (_matrix[4] - _matrix[1]) * _inv
		_dq[3] = -0.25 * s
	} else if _matrix[0] > _matrix[5] and _matrix[0] > _matrix[10] {
		// Column 0:
		s = sqrt(max(0, 1 + _matrix[0] - _matrix[5] - _matrix[10])) * 2
		_inv = 1 / s
		_dq[0] = 0.25 * s
		_dq[1] = (_matrix[4] + _matrix[1]) * _inv
		_dq[2] = (_matrix[2] + _matrix[8]) * _inv
		_dq[3] = (_matrix[9] - _matrix[6]) * _inv
	} else if _matrix[5] > _matrix[10] {
		// Column 1:
		s = sqrt(max(0, 1 + _matrix[5] - _matrix[0] - _matrix[10])) * 2
		_inv = 1 / s
		_dq[0] = (_matrix[4] + _matrix[1]) * _inv
		_dq[1] = 0.25 * s
		_dq[2] = (_matrix[9] + _matrix[6]) * _inv
		_dq[3] = (_matrix[2] - _matrix[8]) * _inv
	} else {
		// Column 2:
		s  = sqrt(max(0, 1 + _matrix[10] - _matrix[0] - _matrix[5])) * 2
		_inv = 1 / s
		_dq[0] = (_matrix[2] + _matrix[8]) * _inv
		_dq[1] = (_matrix[9] + _matrix[6]) * _inv
		_dq[2] = 0.25 * s
		_dq[3] = (_matrix[4] - _matrix[1]) * _inv
	}
	
	_dq[4] = 0.5 * (_matrix[12] * _dq[3] + _matrix[13] * _dq[2] - _matrix[14] * _dq[1])
	_dq[5] = 0.5 * (_matrix[13] * _dq[3] + _matrix[14] * _dq[0] - _matrix[12] * _dq[2])
	_dq[6] = 0.5 * (_matrix[14] * _dq[3] + _matrix[12] * _dq[1] - _matrix[13] * _dq[0])
	_dq[7] = -0.5 * (_matrix[12] * _dq[0] + _matrix[13] * _dq[1] + _matrix[14] * _dq[2])
	
	return _dq
}