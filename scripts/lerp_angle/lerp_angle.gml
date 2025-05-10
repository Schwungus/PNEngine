/// @func lerp_angle(a, b, amount)
/// @param {Real} a
/// @param {Real} b
/// @param {Real} amount
/// @return {Real}
function lerp_angle(_val1, _val2, _amount) {
	gml_pragma("forceinline")
	
	return _val1 + _amount * angle_difference(_val2, _val1)
}