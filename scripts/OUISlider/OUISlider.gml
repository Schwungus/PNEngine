function OUISlider(_name, _current = 0, _step = 1, _min = -infinity, _max = infinity, _format = undefined, _changed = undefined, _disabled = undefined) : OUIElement(_name, undefined, _disabled) constructor {
	current_value = _current
	step_value = _step
	min_value = _min
	max_value = _max
	format = is_method(_format) ? method(self, _format) : undefined
	changed = _changed
	
	static selected = function (_dir) {
		if _dir != 0 {
			current_value = clamp(current_value + (_dir * step_value), min_value, max_value)
			
			if is_method(changed) {
				changed(current_value)
			}
		}
		
		return true
	}
}