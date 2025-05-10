/// @param {Real} x1
/// @param {Real} y1
/// @param {Real} x2
/// @param {Real} y2
/// @param {Real} x3
/// @param {Real} y3
/// @param {Real} x4
/// @param {Real} y4
/// @return {Bool}
function lines_intersect(_x1, _y1, _x2, _y2, _x3, _y3, _x4, _y4) {
	// https://www.gmlscripts.com/script/lines_intersect
	var _ux = _x2 - _x1
	var _uy = _y2 - _y1
	var _vx = _x4 - _x3
	var _vy = _y4 - _y3
	var _wx = _x1 - _x3
	var _wy = _y1 - _y3
	var _ud = _vy * _ux - _vx * _uy
	
	if _ud != 0 {
		var _inv = 1 / _ud
		var _ua = (_vx * _wy - _vy * _wx) * _inv
		var _ub = (_ux * _wy - _uy * _wx) * _inv
		
		if _ua < 0 or _ua > 1 or _ub < 0 or _ub > 1 {
			return false
		}
	}
	
	return true
}