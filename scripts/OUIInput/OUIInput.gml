/// @param {String} name
/// @param {String} current
/// @param {Function|Undefined} changed
/// @param {Function|Undefined} disabled
function OUIInput(_name, _current = "", _changed = undefined, _disabled = undefined) : OUIElement(_name, undefined, _disabled) constructor {
	current_value = _current
	changed = _changed
	
	/// @param {String} value
	/// @return {Bool}
	/// @context OUIInput
	static confirm = function (_value) {
		var _result = is_method(changed) ? changed(_value) : undefined
		
		if _result != undefined {
			current_value = _result
			
			return true
		}
		
		return false
	}
}