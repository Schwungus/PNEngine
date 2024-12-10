/// @description Create
event_inherited()

if is_struct(special) {
	var _yaw = force_type_fallback(special[$ "yaw"], "number", angle)
	var _pitch = force_type_fallback(special[$ "pitch"], "number", 0)
	var _roll = force_type_fallback(special[$ "roll"], "number", 0)
	var _scale = force_type_fallback(special[$ "scale"], "number", 1)
	var _x_scale = force_type_fallback(special[$ "x_scale"], "number", 1)
	var _y_scale = force_type_fallback(special[$ "y_scale"], "number", 1)
	var _z_scale = force_type_fallback(special[$ "z_scale"], "number", 1)
	var _blendmode
	
	switch force_type_fallback(special[$ "blendmode"], "string", "BM_NORMAL") {
		default:
		case "BM_NORMAL": _blendmode = bm_normal break
		case "BM_ADD": _blendmode = bm_add break
		case "BM_MAX": _blendmode = bm_max break
		case "BM_SUBTRACT": _blendmode = bm_subtract break
	}
	
	f_collider_active = force_type_fallback(special[$ "collision"], "bool", f_collider_active)
	yaw_speed = force_type_fallback(special[$ "yaw_speed"], "number", yaw_speed)
	pitch_speed = force_type_fallback(special[$ "pitch_speed"], "number", pitch_speed)
	roll_speed = force_type_fallback(special[$ "roll_speed"], "number", roll_speed)
	
	if model == undefined {
		var _model_name = special[$ "model"]
		
		if not is_string(_model_name) {
			print($"! Prop.create: Invalid model name '{_model}', expected string")
			destroy(false)
			
			exit
		}
		
		var _model = global.models.get(_model_name)
		
		if _model == undefined {
			print($"! Prop.create: Model '{_model_name}' not found")
			destroy(false)
			
			exit
		}
		
		model = new ModelInstance(_model, x, y, z, _yaw, _pitch, _roll, _scale, _x_scale, _y_scale, _z_scale)
		model.blendmode = _blendmode
		
		var _collider = model.model.collider
		
		if _collider != undefined {
			angle = _yaw
			angle_previous = _yaw
			collider = new ColliderInstance(_collider)
			collider.set_matrix(matrix_build(x, y, z, _roll, _pitch, _yaw, _scale * _x_scale, _scale * _y_scale, _scale * _z_scale))
		}
	} else {
		with model {
			yaw = _yaw
			pitch = _pitch
			roll = _roll
			scale = _scale
			x_scale = _x_scale
			y_scale = _y_scale
			z_scale = _z_scale
			blendmode = _blendmode
		}
		
		if collider != undefined {
			angle = _yaw
			angle_previous = _yaw
			collider.set_matrix(matrix_build(x, y, z, _roll, _pitch, _yaw, _scale * _x_scale, _scale * _y_scale, _scale * _z_scale))
		}
	}
} else {
	if model == undefined {
		print("! Prop.create: Special properties invalid or not found")
		destroy(false)
		
		exit
	}
}