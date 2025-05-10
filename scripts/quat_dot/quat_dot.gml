/// @func quat_dot(q1, q2)
/// @param {Array<Real>} q1
/// @param {Array<Real>} q2
/// @return {Real}
function quat_dot(_q1, _q2) {
	gml_pragma("forceinline")
	
	return _q1[0] * _q2[0] + _q1[1] * _q2[1] + _q1[2] * _q2[2] + _q1[3] * _q2[3]
}