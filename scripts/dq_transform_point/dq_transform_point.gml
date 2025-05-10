/// @func dq_transform_point(dq, x, y, z)
/// @param {Array<Real>} dq
/// @param {Real} x
/// @param {Real} y
/// @param {Real} z
/// @return {Array<Real>} XYZ array.
function dq_transform_point(_dq, _x, _y, _z) {
	gml_pragma("forceinline")
	
	var _q0 = _dq[0]
	var _q1 = _dq[1]
	var _q2 = _dq[2]
	var _q3 = _dq[3]
	var d = 1 / sqrt(sqr(_q0) + sqr(_q1) + sqr(_q2) + sqr(_q3))
	
	_q0 *= d
	_q1 *= d
	_q2 *= d
	_q3 *= d
	
	var _ax = _q3 * _x + _q1 * _z - _q2 * _y
	var _ay = _q3 * _y + _q2 * _x - _q0 * _z
	var _az = _q3 * _z + _q0 * _y - _q1 * _x
	var _aw = -_q0 * _x - _q1 * _y - _q2 * _z
	
	var _bx = -_q0
	var _by = -_q1
	var _bz = -_q2
	
	_x = _ax * _q3 + _aw * _bx + _ay * _bz - _az * _by
	_y = _ay * _q3 + _aw * _by + _az * _bx - _ax * _bz
	_z = _az * _q3 + _aw * _bz + _ax * _by - _ay * _bx
	
	var _result = dq_get_translation(_dq)
	
	_result[0] += _x
	_result[1] += _y
	_result[2] += _z
	
	return _result
}