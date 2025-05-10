/// @func dq_build(rad, ax, ay, az, x, y, z)
/// @desc Creates a dual quaternion from an axis angle and a translation vector.
/// @param {Real} rad
/// @param {Real} ax
/// @param {Real} ay
/// @param {Real} az
/// @param {Real} x
/// @param {Real} y
/// @param {Real} z
/// @return {Array<Real>}
function dq_build(_rad, _ax, _ay, _az, _x, _y, _z)  {
	_rad *= 0.5
	
	var _c = cos(_rad)
	var _s = sin(_rad)
	
	_ax *= _s
	_ay *= _s
	_az *= _s
	
	return [
		_ax, _ay, _az, _c,
		0.5 * (_x * _c + _y * _az - _z * _ax),
		0.5 * (_y * _c + _z * _ax - _x * _az),
		0.5 * (_z * _c + _x * _ay - _y * _ax),
		0.5 * (-_x * _ax - _y * _ay - _z * _az),
	]
}