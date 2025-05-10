/// @func matrix_build_dq(dq, [matrix])
/// @param {Array<Real>} dq
/// @param {Array<Real>} [matrix]
/// @return {Array<Real>}
function matrix_build_dq(_dq, _matrix = matrix_build_identity()) {
	gml_pragma("forceinline")
	
	var q0 = _dq[0]
	var q1 = _dq[1]
	var q2 = _dq[2]
	var q3 = _dq[3]
	var q4 = _dq[4]
	var q5 = _dq[5]
	var q6 = _dq[6]
	var q7 = _dq[7]
	
	_matrix[0] = q3 * q3 + q0 * q0 - q1 * q1 - q2 * q2
	_matrix[1] = 2 * (q0 * q1 + q2 * q3)
	_matrix[2] = 2 * (q0 * q2 - q1 * q3)
	_matrix[3] = 0
	_matrix[4] = 2 * (q0 * q1 - q2 * q3)
	_matrix[5] = q3 * q3 - q0 * q0 + q1 * q1 - q2 * q2
	_matrix[6] = 2 * (q1 * q2 + q0 * q3)
	_matrix[7] = 0
	_matrix[8] = 2 * (q0 * q2 + q1 * q3)
	_matrix[9] = 2 * (q1 * q2 - q0 * q3)
	_matrix[10] = q3 * q3 - q0 * q0 - q1 * q1 + q2 * q2
	_matrix[11] = 0
	_matrix[12] = 2 * (-q7 * q0 + q4 * q3 + q6 * q1 - q5 * q2)
	_matrix[13] = 2 * (-q7 * q1 + q5 * q3 + q4 * q2 - q6 * q0)
	_matrix[14] = 2 * (-q7 * q2 + q6 * q3 + q5 * q0 - q4 * q1)
	_matrix[15] = 1
	
	return _matrix
}