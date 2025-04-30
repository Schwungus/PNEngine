function OUIOption(_name, _values = OUIValues.UNDEFINED, _current = 0, _changed = undefined, _disabled = undefined) : OUIElement(_name, undefined, _disabled) constructor {
	values = global.oui_values[_values]
	current_value = _current
	changed = _changed
	
	static selected = function (_dir) {
		if _dir != 0 {
			var n = array_length(values)
			
			current_value = (current_value + _dir) % n
			
			while current_value < 0 {
				current_value += n
			}
			
			if is_method(changed) {
				changed(current_value)
			}
		}
		
		return true
	}
}