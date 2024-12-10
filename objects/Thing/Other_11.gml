/// @description Create
move_angle = angle

if create != undefined {
	catspeak_execute(create)
}

if f_unique {
	var _type = object_index
	
	if thing_script != undefined {
		_type = thing_script.name
	}
	
	if area.count(_type) > 1 {
		destroy(false)
		
		exit
	}
}

if model != undefined {
	var _collider = model.model.collider
	
	if _collider != undefined {
		var _yaw, _pitch, _roll, _scale, _x_scale, _y_scale, _z_scale
		
		with model {
			_yaw = yaw
			_pitch = pitch
			_roll = roll
			_scale = scale
			_x_scale = x_scale
			_y_scale = y_scale
			_z_scale = z_scale
		}
		
		angle = _yaw
		angle_previous = _yaw
		collider = new ColliderInstance(_collider)
		collider.set_matrix(matrix_build(x, y, z, _roll, _pitch, _yaw, _scale * _x_scale, _scale * _y_scale, _scale * _z_scale))
	}
}

imgShadow = global.images.get("imgShadow")

interp("x", "sx")
interp("y", "sy")
interp("z", "sz")
interp("shadow_x", "sshadow_x")
interp("shadow_y", "sshadow_y")
interp("shadow_z", "sshadow_z")