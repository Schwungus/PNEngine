/// @func dq_normalize(dq, [out])
/// @param {Array<Real>} dq
/// @param {Array<Real>} [out]
/// @return {Array<Real>}
function dq_normalize(_dq1, _dq = dq_build_identity()) {
	gml_pragma("forceinline")
	
	var l = 1 / sqrt(sqr(_dq1[0]) + sqr(_dq1[1]) + sqr(_dq1[2]) + sqr(_dq1[3]))
	
	_dq[0] *= l
	_dq[1] *= l
	_dq[2] *= l
	_dq[3] *= l
	
	var d = _dq1[0] * _dq1[4] + _dq1[1] * _dq1[5] + _dq1[2] * _dq1[6] + _dq1[3] * _dq1[7]
	
	_dq[4] = (_dq1[4] - _dq1[0] * d) * l
	_dq[5] = (_dq1[5] - _dq1[1] * d) * l
	_dq[6] = (_dq1[6] - _dq1[2] * d) * l
	_dq[7] = (_dq1[7] - _dq1[3] * d) * l
	
	return _dq
}