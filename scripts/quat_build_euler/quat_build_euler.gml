/// @func quat_build_euler(x, y, z, [q])
/// @param {Real} x
/// @param {Real} y
/// @param {Real} z
/// @param {Array<Real>} [q]
/// @return {Array<Real>}
function quat_build_euler(_x, _y, _z, _q = quat_build()) {
	gml_pragma("forceinline")
	
	_x *= -0.5
	_y *= -0.5
	_z *= -0.5
	
	var _sx = dsin(_x)
	var _sy = dsin(_y)
	var _sz = dsin(_z)
	var _cx = dcos(_x)
	var _cy = dcos(_y)
	var _cz = dcos(_z)
	
	_q[0] = _sx * _cy * _cz + _cx * _sy * _sz
	_q[1] = _cx * _sy * _cz - _sx * _cy * _sz
	_q[2] = _cx * _cy * _sz - _sx * _sy * _cz
	_q[3] = _cx * _cy * _cz + _sx * _sy * _sz
	
	return _q
}