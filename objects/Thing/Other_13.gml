/// @description Tick
if tick_start != undefined {
	catspeak_execute(tick_start)
}

// Source: https://github.com/YoYoGames/GameMaker-HTML5/blob/37ebef72db6b238b892bb0ccc60184d4c4ba5d12/scripts/yyInstance.js#L1157
if fric != 0 {
	var _ns = vector_speed > 0 ? vector_speed - fric : vector_speed + fric
	
	if (vector_speed > 0 and _ns < 0) or (vector_speed < 0 and _ns > 0) {
		set_speed(0)
	} else {
		if vector_speed != 0 {
			set_speed(_ns)
		}
	}
}

if f_gravity and not f_grounded {
	z_speed = clamp(z_speed + (area.gravity * grav), max_fly_speed, max_fall_speed)
}

var _held = thing_exists(holder)

// Thing collision
if not _held and bump_cells != undefined {
	var _bump_stack = global.bump_stack
	var _bump_grid = area.bump_grid
	
	var _cell = _bump_grid[#
		clamp(floor((x - area.bump_x) * COLLIDER_REGION_SIZE_INVERSE), 0, ds_grid_width(_bump_grid) - 1),
		clamp(floor((y - area.bump_y) * COLLIDER_REGION_SIZE_INVERSE), 0, ds_grid_height(_bump_grid) - 1)
	]
	
	var i = ds_list_size(_cell)
	
	while i {
		ds_stack_push(_bump_stack, _cell[| --i])
	}
	
	var _bump_radius = bump_radius ?? radius
	
	repeat ds_stack_size(_bump_stack) {
		var _thing = ds_stack_pop(_bump_stack)
		
		if _thing == self or _thing.holder == self {
			continue
		}
		
		var _tx, _ty, _tz, _th
		
		with _thing {
			_tx = x
			_ty = y
			_tz = z
			_th = height
		}
		
		// Bounding box check
		if z > (_tz - _th) and (z - height) < _tz
			and point_distance(x, y, _tx, _ty) < _bump_radius + (_thing.bump_radius ?? _thing.radius) {
			var _result_me = catspeak_execute(bump_check, _thing, false)
			
			if not thing_exists(self) {
				exit
			}
			
			if _result_me == 0 or not thing_exists(_thing) {
				continue
			}
			
			var _result_from
			
			with _thing {
				_result_from = catspeak_execute(bump_check, other, true)
			}
			
			if not thing_exists(self) {
				exit
			}
			
			if _result_from == 0 or not thing_exists(_thing) or f_bump_passive or _thing.f_bump_passive {
				continue
			}
			
			// Avoid this Thing if all these conditions are met
			var _pusher, _pushed, _pusher_result, _pushed_result
			
			if _thing.f_bump_avoid
				and (f_bump_heavy or point_distance(0, 0, x_speed, y_speed) > point_distance(0, 0, _thing.x_speed, _thing.y_speed)) {
				_pusher = self
				_pushed = _thing
				_pusher_result = _result_me
				_pushed_result = _result_from
			} else {
				if not f_bump_avoid {
					// None of the Things can avoid each other
					continue
				}
				
				_pusher = _thing
				_pushed = self
				_pusher_result = _result_from
				_pushed_result = _result_me
			}
			
			if not _pushed.bump_avoid(_pusher, _pusher_result) and _pusher.f_bump_avoid and (not _pusher.f_bump_heavy or _pushed.f_bump_heavy) {
				_pusher.bump_avoid(_pushed, _pushed_result)
			}
		}
	}
}

// World collision
if _held {
	floor_ray[RaycastData.HIT] = false
	wall_ray[RaycastData.HIT] = false
	ceiling_ray[RaycastData.HIT] = false
	f_grounded = false
} else {
	var _new_x = x
	var _new_y = y
	var _new_z = z
	
	switch m_collision {
		default: {
			_new_x += x_speed
			_new_y += y_speed
			_new_z += z_speed
			floor_ray[RaycastData.HIT] = false
			wall_ray[RaycastData.HIT] = false
			ceiling_ray[RaycastData.HIT] = false
			f_grounded = false
			
			break
		}
	
		case MCollision.NORMAL: {
			var _half_height = height * 0.5
			var _center_z = _new_z - _half_height
			
			// Check the ground first so we don't clip through moving colliders
			var _raycast = raycast(_new_x, _new_y, _center_z, _new_x, _new_y, _new_z, CollisionFlags.BODY)
			
			if _raycast[RaycastData.HIT] {
				_new_z = _raycast[RaycastData.Z]
			}
			
			// X-axis
			if raycast(
				_new_x + min(0, x_speed) - radius, 
				_new_y, 
				_center_z, 
				_new_x + max(0, x_speed) + radius, 
				_new_y, 
				_center_z, 
				CollisionFlags.BODY, 
				CollisionLayers.ALL, 
				wall_ray)[RaycastData.HIT] {
				var _hit_x = wall_ray[RaycastData.X]
				
				if _hit_x < _new_x {
					_new_x = _hit_x + radius
					x_speed = max(x_speed, 0)
				} else {
					_new_x = _hit_x - radius
					x_speed = min(x_speed, 0)
				}
			}
			
			_new_x += x_speed
			
			// Y-axis
			_raycast = raycast(
				_new_x, 
				_new_y + min(0, y_speed) - radius, 
				_center_z, 
				_new_x, 
				_new_y + max(0, y_speed) + radius, 
				_center_z, 
				CollisionFlags.BODY, 
				CollisionLayers.ALL)
			
			if _raycast[RaycastData.HIT] {
				array_copy(wall_ray, 0, _raycast, 0, RaycastData.__SIZE)
				
				var _hit_y = _raycast[RaycastData.Y]
				
				if _hit_y < _new_y {
					_new_y = _hit_y + radius
					y_speed = max(y_speed, 0)
				} else {
					_new_y = _hit_y - radius
					y_speed = min(y_speed, 0)
				}
			}
			
			_new_y += y_speed
			
			// Ceiling
			if raycast(
				_new_x,
				_new_y,
				_center_z,
				_new_x,
				_new_y,
				_new_z + z_speed - height,
				CollisionFlags.BODY,
				CollisionLayers.ALL,
				ceiling_ray)[RaycastData.HIT] {
				_new_z = ceiling_ray[RaycastData.Z] + height
				z_speed = max(z_speed, 0)
			}
			
			// Floor
			var _extra_z = 0
			
			if f_grounded {
				_extra_z += point_distance(0, 0, x_speed, y_speed)
			}
			
			if thing_exists(last_prop) {
				_extra_z += abs(last_prop.collider.delta_matrix[14]) + clamp(z_speed, -1, 0) + 1
				last_prop = noone
			}
			
			if raycast(
				_new_x,
				_new_y,
				_new_z - _half_height,
				_new_x,
				_new_y,
				_new_z + z_speed + _extra_z + math_get_epsilon(),
				CollisionFlags.BODY,
				CollisionLayers.ALL,
				floor_ray)[RaycastData.HIT] {
				_new_z = floor_ray[RaycastData.Z]
				z_speed = 0
				
				// Stick to movers
				var _thing = floor_ray[RaycastData.THING]
				
				if thing_exists(_thing) {
					if _thing.f_collider_stick {
						var _pos = matrix_transform_vertex(_thing.collider.delta_matrix, _new_x, _new_y, _new_z)
						
						_new_x = _pos[0]
						_new_y = _pos[1]
						//_new_z = _pos[2]
						
						var _diff = angle_difference(_thing.angle, _thing.angle_previous)
						
						if model != undefined {
							model.yaw += _diff
						}
						
						angle += _diff
						set_move_angle(move_angle + _diff)
					}
					
					with _thing {
						catspeak_execute(thing_on_prop, other)
					}
				}
				
				last_prop = _thing
				
				var _flags = floor_ray[RaycastData.TRIANGLE][TriangleData.FLAGS]
				
				if ((_flags & CollisionFlags.SLIPPERY) or floor_ray[RaycastData.NZ] >= -0.5) and not (_flags & CollisionFlags.STICKY) {
					var _dir = darctan2(-floor_ray[RaycastData.NY], floor_ray[RaycastData.NX])
					
					_new_x += dcos(_dir)
					_new_y -= dsin(_dir)
					f_grounded = false
				} else {
					f_grounded = true
				}
			} else {
				f_grounded = false
			}
			
			_new_z += z_speed
			
			break
		}
	}
	
	set_position(_new_x, _new_y, _new_z)
}

if tick != undefined {
	catspeak_execute(tick)
}

var _is_holding = thing_exists(holding) 

if _is_holding {
	holding.set_position(x, y, z - height)
	holding.angle = angle
	holding.set_speed(0)
	holding.z_speed = 0
}

var _model = model

if _model != undefined and not _held {
	var _x = x
	var _y = y
	var _z = z
	var _update_collider = false
	
	if collider != undefined {
		var _yaw, _pitch, _roll, _scale, _x_scale, _y_scale, _z_scale
		
		with _model {
			_yaw = yaw
			_pitch = pitch
			_roll = roll
			_scale = scale
			_x_scale = x_scale
			_y_scale = y_scale
			_z_scale = z_scale
		}
		
		angle = _yaw
		_update_collider = true
	}
	
	_model.tick()
	
	if _update_collider {
		collider.set_matrix(_model.tick_matrix)
	}
	
	if _is_holding {
		if holding.f_holdable_in_hand {
			var _hold_bone = _model.hold_bone
			
			if _hold_bone != -1 {
				with holding {
					if model != undefined {
						with model {
							x = _x
							y = _y
							z = _z
							matrix_build_dq(_model.get_node_dq(_hold_bone, true), tick_matrix)
							tick_matrix = matrix_multiply(matrix_multiply(hold_offset_matrix, tick_matrix), _model.tick_matrix)
							tick(false)
						}
					}
				}
			}
		} else {
			catspeak_execute(holder_attach_holdable, holding)
			
			with holding {
				if model != undefined {
					_x = x
					_y = y
					_z = z
					
					with model {
						x = _x
						y = _y
						z = _z
						yaw = _model.yaw
						tick()
					}
				}
			}
		}
	}
}

if _held {
	shadow_ray[RaycastData.HIT] = false
} else {
	switch m_shadow {
		default:
		case MShadow.NONE: shadow_ray[RaycastData.HIT] = false break
		
		case MShadow.NORMAL:
		case MShadow.BONE:
		case MShadow.MODEL:
			var _x, _y, _z
			
			if m_shadow == MShadow.BONE and model != undefined {
				with model {
					if torso_bone <= -1 {
						_x = x
						_y = y
						_z = z - other.height * 0.5
						
						break
					}
					
					var _bone_pos = get_node_pos(torso_bone)
					
					_x = _bone_pos[0]
					_y = _bone_pos[1]
					_z = _bone_pos[2]
				}
			} else {
				_x = x
				_y = y
				_z = z - height * 0.5
			}
			
			var _has_blob = shadow_ray[RaycastData.HIT]
			
			if raycast(_x, _y, _z, _x, _y, _z + 2000, CollisionFlags.SHADOW, CollisionLayers.ALL, shadow_ray)[RaycastData.HIT] {
				shadow_x = shadow_ray[RaycastData.X]
				shadow_y = shadow_ray[RaycastData.Y]
				shadow_z = shadow_ray[RaycastData.Z]
				
				if not _has_blob {
					interp_skip("sshadow_x")
					interp_skip("sshadow_y")
					interp_skip("sshadow_z")
				}
			}
		break
	}
}

if tick_end != undefined {
	catspeak_execute(tick_end)
}