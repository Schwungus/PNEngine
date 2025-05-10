/// @param {Any} default
/// @param {Function} [process]
/// @param {Function|Undefined} [update]
function CVar(_default, _process = is_numeric, _update = undefined) constructor {
	value = _default
	default_value = _default
	process = method(self, _process)
	update = _update != undefined ? method(self, _update) : undefined
	
	/// @param {Any} value
	/// @param {Bool} [update]
	/// @return {Real}
	/// @context CVar
	static set = function (_value, _update = true) {
		if not process(_value) {
			return -1
		}
		
		if _value == value {
			return 0
		}
		
		value = _value
		
		if _update and update != undefined {
			update(false)
		}
		
		return 1
	}
}