/// @func lerp3(a, b, c, amount)
/// @desc Lerps through 3 points.
/// @param {Real} a
/// @param {Real} b
/// @param {Real} c
/// @param {Real} amount
/// @return {Real}
function lerp3(_val1, _val2, _val3, _amount) {
	gml_pragma("forceinline")
	
	return sqr(1 - _amount) * _val1 + 2 * (1 - _amount) * _amount * _val2 + sqr(_amount) * _val3
}