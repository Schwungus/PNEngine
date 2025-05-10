/// @func dq_get_z(dq)
/// @desc Returns the Z position of a dual quaternion.
/// @param {Array<Real>} dq
/// @return {Real}
function dq_get_z(_dq) {
	gml_pragma("forceinline")
	
	return 2 * (-_dq[7] * _dq[2] + _dq[6] * _dq[3] + _dq[5] * _dq[0] - _dq[4] * _dq[1])
}