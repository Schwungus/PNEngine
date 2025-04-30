function OUIElement(_name, _callback = undefined, _disabled = undefined) constructor {
	menu = undefined
	slot = -1
	
	name = _name
	callback = _callback
	disabled = _disabled
	
	static select = function (_dir = 0) {
		var _result = true
		
		if is_method(callback) {
			_result = callback()
		}
		
		return _result and selected(_dir)
	}
	
	static selected = function (_dir) {
		return true
	}
}