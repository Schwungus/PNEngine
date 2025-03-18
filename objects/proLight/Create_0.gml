event_inherited()
light_data = undefined
handle = -1
offset = 0
type = LightTypes.NONE
active = 2
arg0 = 0
arg1 = 0
arg2 = 0
arg3 = 0
arg4 = 0
arg5 = 0
interp("arg0", "sarg0")
interp("arg1", "sarg1")
interp("arg2", "sarg2")
interp("arg3", "sarg3")
interp("arg4", "sarg4")
interp("arg5", "sarg5")
color = c_white
alpha = 1

#region Virtual Functions
update_args = function () {}
#endregion

#region Events
Thing_event_create = event_create

event_create = function () {
	Thing_event_create()
	light_data = area.light_data
	
	var _color = undefined
	
	if is_struct(special) {
		_color = special[$ "color"]
		active = force_type_fallback(special[$ "active"], "number", active)
	}
	
	if _color != undefined {
		// integer
		if is_real(_color) {
			color = _color
		}
		
		// vec2, vec3 or vec4
		if is_array(_color) {
			switch array_length(_color) {
				case 2: {
					color = _color[0]
					alpha = _color[1]
					
					if not is_real(color) or not is_real(alpha) {
						show_error("!!! proLight: Invalid vec2 array, elements must be real", true)
					}
					
					break
				}
				
				case 3: {
					var _r = _color[0]
					var _g = _color[1]
					var _b = _color[2]
					
					if not is_real(_r) or not is_real(_g) or not is_real(_b) {
						show_error("!!! proLight: Invalid vec3 array, elements must be real", true)
					}
					
					color = make_color_rgb(_r * 255, _g * 255, _b * 255)
					
					break
				}
				
				case 4: {
					var _r = _color[0]
					var _g = _color[1]
					var _b = _color[2]
					
					alpha = _color[3]
					
					if not is_real(_r) or not is_real(_g) or not is_real(_b) or not is_real(alpha) {
						show_error("!!! proLight: Invalid vec4 array, elements must be real", true)
					}
					
					color = make_color_rgb(_r * 255, _g * 255, _b * 255)
					
					break
				}
			}
		}
	}
	
	var _lights = area.lights
	
	handle = ds_list_find_index(_lights, noone)
	
	if handle != -1 {
		_lights[| handle] = self
		offset = handle * LightData.__SIZE
		light_data[offset + LightData.TYPE] = type
		light_data[offset + LightData.ACTIVE] = active
		light_data[offset + LightData.X] = x
		light_data[offset + LightData.Y] = y
		light_data[offset + LightData.Z] = z
		light_data[offset + LightData.ARG0] = arg0
		light_data[offset + LightData.ARG1] = arg1
		light_data[offset + LightData.ARG2] = arg2
		light_data[offset + LightData.ARG3] = arg3
		light_data[offset + LightData.ARG4] = arg4
		light_data[offset + LightData.ARG5] = arg5
		light_data[offset + LightData.RED] = color_get_red(color) * COLOR_INVERSE
		light_data[offset + LightData.GREEN] = color_get_green(color) * COLOR_INVERSE
		light_data[offset + LightData.BLUE] = color_get_blue(color) * COLOR_INVERSE
		light_data[offset + LightData.ALPHA] = alpha
	}
}

event_draw = function () {
	if handle != -1 {
		light_data[offset + LightData.ACTIVE] = active
		light_data[offset + LightData.X] = sx
		light_data[offset + LightData.Y] = sy
		light_data[offset + LightData.Z] = sz
		light_data[offset + LightData.ARG0] = sarg0
		light_data[offset + LightData.ARG1] = sarg1
		light_data[offset + LightData.ARG2] = sarg2
		light_data[offset + LightData.ARG3] = sarg3
		light_data[offset + LightData.ARG4] = sarg4
		light_data[offset + LightData.ARG5] = sarg5
		light_data[offset + LightData.RED] = color_get_red(color) * COLOR_INVERSE
		light_data[offset + LightData.GREEN] = color_get_green(color) * COLOR_INVERSE
		light_data[offset + LightData.BLUE] = color_get_blue(color) * COLOR_INVERSE
		light_data[offset + LightData.ALPHA] = alpha
	}
}
#endregion