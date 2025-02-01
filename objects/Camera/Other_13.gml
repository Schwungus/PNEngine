/// @description Tick
event_inherited()

update_targets()
update_pois()

if not f_predicting {
	if path_active {
		// Camera animation
		var _nodes = ds_grid_width(path)
		
		if path_quadratic {
			var _last_node = _nodes - 1
			
			var _pos = (path_elapsed / path_time) * _nodes
			var _idx = min(floor(_pos), _last_node)
			var _idx_previous = max(_idx - 1, 0)
			var _idx_next = min(_last_node, -~_idx)
			
			_pos -= _idx // _pos is now (0..1)
			
			// previous\current\next values:
			var _x_p = path[# _idx_previous, CameraPathData.X]
			var _x_c = path[# _idx, CameraPathData.X]
			var _x_n = path[# _idx_next, CameraPathData.X]
			var _y_p = path[# _idx_previous, CameraPathData.Y]
			var _y_c = path[# _idx, CameraPathData.Y]
			var _y_n = path[# _idx_next, CameraPathData.Y]
			var _z_p = path[# _idx_previous, CameraPathData.Z]
			var _z_c = path[# _idx, CameraPathData.Z]
			var _z_n = path[# _idx_next, CameraPathData.Z]
			
			var _yaw_p = path[# _idx_previous, CameraPathData.YAW]
			var _yaw_c = path[# _idx, CameraPathData.YAW]
			var _yaw_n = path[# _idx_next, CameraPathData.YAW]
			var _pitch_p = path[# _idx_previous, CameraPathData.PITCH]
			var _pitch_c = path[# _idx, CameraPathData.PITCH]
			var _pitch_n = path[# _idx_next, CameraPathData.PITCH]
			var _roll_p = path[# _idx_previous, CameraPathData.ROLL]
			var _roll_c = path[# _idx, CameraPathData.ROLL]
			var _roll_n = path[# _idx_next, CameraPathData.ROLL]
			
			var _fov_p = path[# _idx_previous, CameraPathData.FOV]
			var _fov_c = path[# _idx, CameraPathData.FOV]
			var _fov_n = path[# _idx_next, CameraPathData.FOV]
			
			set_position(
				0.5 * (((_x_p - 2 * _x_c + _x_n) * _pos + 2 * (_x_c - _x_p)) * _pos + _x_p + _x_c),
				0.5 * (((_y_p - 2 * _y_c + _y_n) * _pos + 2 * (_y_c - _y_p)) * _pos + _y_p + _y_c),
				0.5 * (((_z_p - 2 * _z_c + _z_n) * _pos + 2 * (_z_c - _z_p)) * _pos + _z_p + _z_c)
			)
			
			yaw = 0.5 * (((_yaw_p - 2 * _yaw_c + _yaw_n) * _pos + 2 * (_yaw_c - _yaw_p)) * _pos + _yaw_p + _yaw_c)
			pitch = 0.5 * (((_pitch_p - 2 * _pitch_c + _pitch_n) * _pos + 2 * (_pitch_c - _pitch_p)) * _pos + _pitch_p + _pitch_c)
			roll = 0.5 * (((_roll_p - 2 * _roll_c + _roll_n) * _pos + 2 * (_roll_c - _roll_p)) * _pos + _roll_p + _roll_c)
			
			fov = 0.5 * (((_fov_p - 2 * _fov_c + _fov_n) * _pos + 2 * (_fov_c - _fov_p)) * _pos + _fov_p + _fov_c)
		} else {
			var a = 0
			var b = 0
			var d = 0
			
			repeat _nodes {
				if path[# b, CameraPathData.TIME] >= path_elapsed {
					break
				}
				
				++b
			}
			
			if path_loop {
				a = (b - 1 + _nodes) % _nodes
			} else {
				if b == 0 {
					b = _nodes - 1
					a = b
				} else {
					a = max(b - 1, 0)
				}
			}
			
			if a != b {
				var mb = path[# b, CameraPathData.TIME]
				
				mb += path_elapsed > mb
				
				var ma = path[# a, CameraPathData.TIME]
				
				ma -= ma > mb
				d = mb == ma ? 0 : (path_elapsed - ma) / (mb - ma)
			}
			
			set_position(
				lerp(path[# a, CameraPathData.X], path[# b, CameraPathData.X], d),
				lerp(path[# a, CameraPathData.Y], path[# b, CameraPathData.Y], d),
				lerp(path[# a, CameraPathData.Z], path[# b, CameraPathData.Z], d)
			)
			
			yaw = lerp_angle(path[# a, CameraPathData.YAW], path[# b, CameraPathData.YAW], d)
			pitch = lerp_angle(path[# a, CameraPathData.PITCH], path[# b, CameraPathData.PITCH], d)
			roll = lerp_angle(path[# a, CameraPathData.ROLL], path[# b, CameraPathData.ROLL], d)
			
			fov = lerp(path[# a, CameraPathData.FOV], path[# b, CameraPathData.FOV], d)
		}
		
		++path_elapsed
		path_elapsed = path_loop ? path_elapsed % path_time : min(path_elapsed, path_time)
	}
	
	if quake > 0 {
		quake -= 1
		
		if quake <= 0 {
			quake_x = 0
			quake_y = 0
			quake_z = 0
		} else {
			var a = -quake
			var b = quake
			
			quake_x = random_range(a, b)
			quake_y = random_range(a, b)
			quake_z = random_range(a, b)
		}
	}
}