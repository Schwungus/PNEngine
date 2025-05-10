/// @func RNG([state])
/// @param {Real} [state] Initial seed.
function RNG(_state = 0) constructor {
	state = _state
	
	/// @return {Real}
	/// @context RNG
	static next = function () {
		state = (state * 1103515245 + 12345) & 0x7FFFFFFF
		
		return state
	}
	
	/// @func int(x)
	/// @param {Real} x
	/// @return {Real}
	/// @context RNG
	static int = function (_x = 1) {
		gml_pragma("forceinline")
		
		return round((next() / 0x7FFFFFFF) * _x)
	}
	
	/// @func int_range(x, y)
	/// @param {Real} x
	/// @param {Real} y
	/// @return {Real}
	/// @context RNG
	static int_range = function (_x, _y) {
		gml_pragma("forceinline")
		
		return round(lerp(_x, _y, next() / 0x7FFFFFFF))
	}
	
	/// @func int_sign(x)
	/// @param {Real} x
	/// @return {Real}
	/// @context RNG
	static int_sign = function (_x = 1) {
		gml_pragma("forceinline")
		
		return int_range(-_x, _x)
	}
	
	/// @func float(x)
	/// @param {Real} x
	/// @return {Real}
	/// @context RNG
	static float = function (_x = 1) {
		gml_pragma("forceinline")
		
		return (next() / 0x7FFFFFFF) * _x
	}
	
	/// @func float_range(x, y)
	/// @param {Real} x
	/// @param {Real} y
	/// @return {Real}
	/// @context RNG
	static float_range = function (_x, _y) {
		gml_pragma("forceinline")
		
		return lerp(_x, _y, next() / 0x7FFFFFFF)
	}
	
	/// @func float_sign(x)
	/// @param {Real} x
	/// @return {Real}
	/// @context RNG
	static float_sign = function (_x = 1) {
		gml_pragma("forceinline")
		
		return float_range(-_x, _x)
	}
	
	/// @return {Any}
	/// @context RNG
	static pick = function () {
		gml_pragma("forceinline")
		
		var _argc = argument_count
		
		if _argc != 0 {
			return argument[int(_argc - 1)]
		}
		
		return undefined
	}
}

global.rng_game = new RNG()
global.rng_visual = new RNG()