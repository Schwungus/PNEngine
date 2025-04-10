function RNG(_state = 0) constructor {
	state = _state
	
	static next = function () {
		state = (state * 1103515245 + 12345) & 0x7FFFFFFF
		
		return state
	}
	
	static int = function (_x = 1) {
		gml_pragma("forceinline")
		
		return round((next() / 0x7FFFFFFF) * _x)
	}
	
	static int_range = function (_x, _y) {
		gml_pragma("forceinline")
		
		return round(lerp(_x, _y, next() / 0x7FFFFFFF))
	}
	
	static int_sign = function (_x = 1) {
		gml_pragma("forceinline")
		
		return int_range(-_x, _x)
	}
	
	static float = function (_x = 1) {
		gml_pragma("forceinline")
		
		return (next() / 0x7FFFFFFF) * _x
	}
	
	static float_range = function (_x, _y) {
		gml_pragma("forceinline")
		
		return lerp(_x, _y, next() / 0x7FFFFFFF)
	}
	
	static float_sign = function (_x = 1) {
		gml_pragma("forceinline")
		
		return float_range(-_x, _x)
	}
	
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