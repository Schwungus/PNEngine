/// @param {String} name
/// @param {Function|Undefined} callback
/// @param {Function|Undefined} disabled
function OUIElement(_name, _callback = undefined, _disabled = undefined) constructor {
	menu = undefined
	slot = -1
	
	name = _name
	callback = _callback
	disabled = _disabled
	
	/// @param {Real} dir
	/// @return {Bool}
	/// @context OUIElement
	static select = function (_dir = 0) {
		var _result = true
		
		if is_method(callback) {
			_result = callback()
		}
		
		return _result and selected(_dir)
	}
	
	/// @param {Real} dir
	/// @return {Bool}
	/// @context OUIElement
	static selected = function (_dir) {
		return true
	}
}