/// @func dq_lerp(dq1, dq2, amount, [out])
/// @param {Array<Real>} dq1
/// @param {Array<Real>} dq2
/// @param {Real} amount
/// @param {Array<Real>} [out]
/// @return {Array<Real>}
function dq_lerp(_dq1, _dq2, _amount, _dq = dq_build_identity()) {
	gml_pragma("forceinline")
	
	_dq[0] = lerp(_dq1[0], _dq2[0], _amount)
	_dq[1] = lerp(_dq1[1], _dq2[1], _amount)
	_dq[2] = lerp(_dq1[2], _dq2[2], _amount)
	_dq[3] = lerp(_dq1[3], _dq2[3], _amount)
	_dq[4] = lerp(_dq1[4], _dq2[4], _amount)
	_dq[5] = lerp(_dq1[5], _dq2[5], _amount)
	_dq[6] = lerp(_dq1[6], _dq2[6], _amount)
	_dq[7] = lerp(_dq1[7], _dq2[7], _amount)
	
	return _dq
}