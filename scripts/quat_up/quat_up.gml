/// @func quat_multiply(q, [out])
/// @param {Array<Real>} q
/// @param {Array<Real>|Undefined} [out]
/// @return {Array<Real>}
function quat_up(_q1, _out = undefined) {
	gml_pragma("forceinline")
	
	static _temp = array_create(3)
	
	_out ??= _temp
	
	var _x = _q1[0]
	var _y = _q1[1]
	var _z = _q1[2]
	var _w = _q1[3]
	
	_out[0] = 2 * (_z * _x + _w * _y)
	_out[1] = 2 * (_z * _y - _w * _x)
	_out[2] = sqr(_w) - sqr(_x) - sqr(_y) + sqr(_z)
	
	return _out
}