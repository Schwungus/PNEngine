/// @func dq_lerp_array(dq1, dq2, amount, [out])
/// @param {Array<Real>} dq1
/// @param {Array<Real>} dq2
/// @param {Real} amount
/// @param {Array<Real>} [out]
/// @return {Array<Real>}
function dq_lerp_array(_dq1, _dq2, _amount, _dq = dq_build_identity()) {
	gml_pragma("forceinline")
	
	var i = 0
	
	repeat array_length(_dq1) >> 3 {
		var _i1 = -~i
		var _i2 = i + 2
		var _i3 = i + 3
		var _i4 = i + 4
		var _i5 = i + 5
		var _i6 = i + 6
		var _i7 = i + 7
		var s = sign(_dq1[i] * _dq2[i] + _dq1[_i1] * _dq2[_i1] + _dq1[_i2] * _dq2[_i2] + _dq1[_i3] * _dq2[_i3])
		
		_dq[i] = lerp(_dq1[i], _dq2[i] * s, _amount)
		_dq[_i1] = lerp(_dq1[_i1], _dq2[_i1] * s, _amount)
		_dq[_i2] = lerp(_dq1[_i2], _dq2[_i2] * s, _amount)
		_dq[_i3] = lerp(_dq1[_i3], _dq2[_i3] * s, _amount)
		_dq[_i4] = lerp(_dq1[_i4], _dq2[_i4] * s, _amount)
		_dq[_i5] = lerp(_dq1[_i5], _dq2[_i5] * s, _amount)
		_dq[_i6] = lerp(_dq1[_i6], _dq2[_i6] * s, _amount)
		_dq[_i7] = lerp(_dq1[_i7], _dq2[_i7] * s, _amount)
		i += 8
	}
}