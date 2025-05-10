/// @func dq_get_translation(dq, [out])
/// @desc Returns the translation of a dual quaternion.
/// @param {Array<Real>} dq
/// @param {Array<Real>} [out]
/// @return {Array<Real}
function dq_get_translation(_dq, _out = undefined) {
	gml_pragma("forceinline")
	
	static _temp = array_create(3)
	
	_out ??= _temp
	
	var _q10 = _dq[4] * 2
	var _q11 = _dq[5] * 2
	var _q12 = _dq[6] * 2
	var _q13 = _dq[7] * 2
	
	var _q20 = -_dq[0]
	var _q21 = -_dq[1]
	var _q22 = -_dq[2]
	var _q23 = _dq[3]
	
	_out[0] = _q13 * _q20 + _q10 * _q23 + _q11 * _q22 - _q12 * _q21
	_out[1] = _q13 * _q21 + _q11 * _q23 + _q12 * _q20 - _q10 * _q22
	_out[2] = _q13 * _q22 + _q12 * _q23 + _q10 * _q21 - _q11 * _q20
	
	return _out
}