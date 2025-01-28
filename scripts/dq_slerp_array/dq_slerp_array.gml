function dq_slerp_array(_dq1, _dq2, _amount, _dq = dq_build_identity()) {
	var i = 0
	
	repeat array_length(_dq1) >> 3 {
		var i1 = -~i
		var i2 = i + 2
		var i3 = i + 3
		var i4 = i + 4
		var i5 = i + 5
		var i6 = i + 6
		var i7 = i + 7
		
		// First dual quaternion
		var _dq10 = _dq1[i]
		var _dq11 = _dq1[i1]
		var _dq12 = _dq1[i2]
		var _dq13 = _dq1[i3]
		// (* 2 since we use this only in the translation reconstruction)
		var _dq14 = _dq1[i4] * 2
		var _dq15 = _dq1[i5] * 2
		var _dq16 = _dq1[i6] * 2
		var _dq17 = _dq1[i7] * 2
		
		// Second dual quaternion
		var _dq20 = _dq2[i]
		var _dq21 = _dq2[i1]
		var _dq22 = _dq2[i2]
		var _dq23 = _dq2[i3]
		// (* 2 since we use this only in the translation reconstruction)
		var _dq24 = _dq2[i4] * 2
		var _dq25 = _dq2[i5] * 2
		var _dq26 = _dq2[i6] * 2
		var _dq27 = _dq2[i7] * 2
		
		// Lerp between reconstructed translations
		var _pos0 = lerp(
			_dq17 * (-_dq10) + _dq14 * _dq13 + _dq15 * (-_dq12) - _dq16 * (-_dq11),
			_dq27 * (-_dq20) + _dq24 * _dq23 + _dq25 * (-_dq22) - _dq26 * (-_dq21),
			_amount
		)
		
		var _pos1 = lerp(
			_dq17 * (-_dq11) + _dq15 * _dq13 + _dq16 * (-_dq10) - _dq14 * (-_dq12),
			_dq27 * (-_dq21) + _dq25 * _dq23 + _dq26 * (-_dq20) - _dq24 * (-_dq22),
			_amount
		)
		
		var _pos2 = lerp(
			_dq17 * (-_dq12) + _dq16 * _dq13 + _dq14 * (-_dq11) - _dq15 * (-_dq10),
			_dq27 * (-_dq22) + _dq26 * _dq23 + _dq24 * (-_dq21) - _dq25 * (-_dq20),
			_amount
		)
		
		// Slerp rotations and store result into _dq1
		var _norm = 1 / sqrt(_dq10 * _dq10 + _dq11 * _dq11 + _dq12 * _dq12 + _dq13 * _dq13)
		
		_dq10 *= _norm
		_dq11 *= _norm
		_dq12 *= _norm
		_dq13 *= _norm
		
		_norm = sqrt(_dq20 * _dq20 + _dq21 * _dq21 + _dq22 * _dq22 + _dq23 * _dq23)
		
		_dq20 *= _norm
		_dq21 *= _norm
		_dq22 *= _norm
		_dq23 *= _norm
		
		var _dot = _dq10 * _dq20 + _dq11 * _dq21 + _dq12 * _dq22 + _dq13 * _dq23
		
		if _dot < 0 {
			_dot = -_dot
			_dq20 *= -1
			_dq21 *= -1
			_dq22 *= -1
			_dq23 *= -1
		}
		
		if _dot > 0.9995 {
			_dq10 = lerp(_dq10, _dq20, _amount)
			_dq11 = lerp(_dq11, _dq21, _amount)
			_dq12 = lerp(_dq12, _dq22, _amount)
			_dq13 = lerp(_dq13, _dq23, _amount)
		} else {
			var _theta0 = arccos(_dot)
			var _theta = _theta0 * _amount
			var _s2 = sin(_theta) / sin(_theta0)
			var _s1 = cos(_theta) - (_dot * _s2)
			
			_dq10 = (_dq10 * _s1) + (_dq20 * _s2)
			_dq11 = (_dq11 * _s1) + (_dq21 * _s2)
			_dq12 = (_dq12 * _s1) + (_dq22 * _s2)
			_dq13 = (_dq13 * _s1) + (_dq23 * _s2)
		}
		
		// Create new dual quaternion from translation and rotation
		// and write it into the frame
		_dq[i] = _dq10
		_dq[i1] = _dq11
		_dq[i2] = _dq12
		_dq[i3] = _dq13
		_dq[i4] = (_pos0 * _dq13 + _pos1 * _dq12 - _pos2 * _dq11) * 0.5
		_dq[i5] = (_pos1 * _dq13 + _pos2 * _dq10 - _pos0 * _dq12) * 0.5
		_dq[i6] = (_pos2 * _dq13 + _pos0 * _dq11 - _pos1 * _dq10) * 0.5
		_dq[i7] = (-_pos0 * _dq10 - _pos1 * _dq11 - _pos2 * _dq12) * 0.5
		i += 8
	}
	
	return _dq
}