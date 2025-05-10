/// @func quat_multiply(q1, q2, [q])
/// @param {Array<Real>} q1
/// @param {Array<Real>} q2
/// @param {Array<Real>} [q]
/// @return {Array<Real>}
function quat_multiply(_q1, _q2, _q = quat_build()) {
	var _ax = _q1[0]
	var _ay = _q1[1]
	var _az = _q1[2]
	var _aw = _q1[3]
	var _bx = _q2[0]
	var _by = _q2[1]
	var _bz = _q2[2]
	var _bw = _q2[3]
	
	_q[0] = _ax * _bw + _aw * _bx + _ay * _bz - _az * _by
	_q[1] = _ay * _bw + _aw * _by + _az * _bx - _ax * _bz
	_q[2] = _az * _bw + _aw * _bz + _ax * _by - _ay * _bx
	_q[3] = _aw * _bw - _ax * _bx - _ay * _by - _az * _bz
	
	return _q
}