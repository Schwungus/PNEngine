function color_to_vec5(_value, _default_color = c_white, _default_alpha = 1) {
	var _r, _g, _b, _a, _color
	
	// hex
	if is_string(_value) {
		_value = real(_value)
	}
	
	// integer
	if is_real(_value) {
		_r = color_get_red(_value) * COLOR_INVERSE
		_g = color_get_green(_value) * COLOR_INVERSE
		_b = color_get_blue(_value) * COLOR_INVERSE
		_a = _default_alpha
		_color = _value
		
		return [_r, _g, _b, _a, _color]
	}
	
	// vec2, vec3 or vec4
	if is_array(_value) {
		switch array_length(_value) {
			case 2:
				_color = real(_value[0])
				_a = _value[1]
				
				if is_real(_a) {
					show_error("!!! color_to_vec5: Invalid vec2 array, alpha must be real", true)
				}
				
				_r = color_get_red(_color) * COLOR_INVERSE
				_g = color_get_green(_color) * COLOR_INVERSE
				_b = color_get_blue(_color) * COLOR_INVERSE
				
				return [_r, _g, _b, _a, _color]
			
			case 3:
				_r = _value[0]
				_g = _value[1]
				_b = _value[2]
				
				if not is_real(_r) or not is_real(_g) or not is_real(_b) {
					show_error("!!! color_to_vec5: Invalid vec3 array, elements must be real", true)
				}
				
				_a = _default_alpha
				_color = make_color_rgb(_r * 255, _g * 255, _b * 255)
				
				return [_r, _g, _b, _a, _color]
				
			case 4:
				_r = _value[0]
				_g = _value[1]
				_b = _value[2]
				_a = _value[3]
				
				if not is_real(_r) or not is_real(_g) or not is_real(_b) or not is_real(_a) {
					show_error("!!! color_to_vec5: Invalid vec4 array, elements must be real", true)
				}
				
				_color = make_color_rgb(_r * 255, _g * 255, _b * 255)
				
				return [_r, _g, _b, _a, _color]
		}
	}
	
	_r = color_get_red(_default_color) * COLOR_INVERSE
	_g = color_get_green(_default_color) * COLOR_INVERSE
	_b = color_get_blue(_default_color) * COLOR_INVERSE
	_a = _default_alpha
	_color = _default_color
	
	return [_r, _g, _b, _a, _color]
}