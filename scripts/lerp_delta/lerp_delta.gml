/// @func lerp_delta(a, b, amount)
/// @desc Lerps from A to B using delta time. (NON-DETERMINISTIC)
/// @param {Real} a
/// @param {Real} b
/// @param {Real} amount
/// @return {Real}
function lerp_delta(val1, val2, amount) {
	gml_pragma("forceinline")
	
	return lerp(val1, val2, min(amount * global.delta, 1))
}