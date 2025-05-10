/// @func dq_conjugate(dq, [out])
/// @desc Creates a conjugate of a dual quaternion.
/// @param {Array<Real>} dq
/// @param {Array<Real>} [out]
/// @return {Array<Real>}
function dq_conjugate(_dq1, _dq = dq_build_identity()) {
	gml_pragma("forceinline")
	
	_dq[0] = -_dq1[0]
	_dq[1] = -_dq1[1]
	_dq[2] = -_dq1[2]
	_dq[3] = _dq1[3]
	_dq[4] = -_dq1[4]
	_dq[5] = -_dq1[5]
	_dq[6] = -_dq1[6]
	_dq[7] = _dq1[7]
	
	return _dq
}