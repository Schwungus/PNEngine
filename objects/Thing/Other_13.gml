/// @description Tick
var _ticking = not f_predicting

if _ticking {
	x_previous = x
	y_previous = y
	z_previous = z
	angle_previous = angle
	
	if tick_start != undefined {
		catspeak_execute(tick_start)
	}
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

var _held = instance_exists(holder)

// Thing collision
if _ticking and not _held and f_bump {
	var _bump_lists = area.bump_lists
	var _gx = clamp(floor((x - area.bump_x) * COLLIDER_REGION_SIZE_INVERSE), 0, ds_grid_width(_bump_lists) - 1)
	var _gy = clamp(floor((y - area.bump_y) * COLLIDER_REGION_SIZE_INVERSE), 0, ds_grid_height(_bump_lists) - 1)
	var _list = _bump_lists[# _gx, _gy]
	var i = ds_list_size(_list)
	
	while i {
		var _thing = _list[| --i]
		
		if instance_exists(_thing) and _thing != self and not instance_exists(_thing.holder) {
			var _tx, _ty, _tz, _th
			
			with _thing {
				_tx = x
				_ty = y
				_tz = z
				_th = height
			}
			
			// Bounding box check
			if z > (_tz - _th) and (z - height) < _tz
			   and point_distance(x, y, _tx, _ty) < bump_radius + _thing.bump_radius {
				var _result_me = catspeak_execute(bump_check, _thing, false)
				
				if not instance_exists(self) {
					exit
				}
				
				if _result_me == 0 or not instance_exists(_thing) {
					continue
				}
				
				var _result_from
				
				with _thing {
					_result_from = catspeak_execute(bump_check, other, true)
				}
				
				if not instance_exists(self) {
					exit
				}
				
				if _result_from == 0 or not instance_exists(_thing) or f_bump_passive or _thing.f_bump_passive {
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
}

// World collision
if _held {
	floor_ray[RaycastData.HIT] = false
	wall_ray[RaycastData.HIT] = false
	ceiling_ray[RaycastData.HIT] = false
	f_grounded = false
} else {
	switch m_collision {
		default:
			x += x_speed
			y += y_speed
			z += z_speed
			floor_ray[RaycastData.HIT] = false
			wall_ray[RaycastData.HIT] = false
			ceiling_ray[RaycastData.HIT] = false
			f_grounded = false
			
			break
	
		case MCollision.NORMAL: {
			var _half_height = height * 0.5
			var _center_z = z - _half_height
			
			// Check the ground first so we don't clip through moving colliders
			var _raycast = raycast(x, y, _center_z, x, y, z, CollisionFlags.BODY)
			
			if _raycast[RaycastData.HIT] {
				z = _raycast[RaycastData.Z]
			}
			
			// X-axis
			if raycast(
				x + min(0.1, x_speed) - radius, 
				y, 
				_center_z, 
				x + max(-0.1, x_speed) + radius, 
				y, 
				_center_z, 
				CollisionFlags.BODY, 
				CollisionLayers.ALL, 
				wall_ray)[RaycastData.HIT] {
				var _hit_x = wall_ray[RaycastData.X]
				
				x = _hit_x + (_hit_x < x ? radius : -radius)
				x_speed = 0
			}
		
			x += x_speed
		
			// Y-axis
			_raycast = raycast(
				x, 
				y + min(0.1, y_speed) - radius, 
				_center_z, 
				x, 
				y + max(-0.1, y_speed) + radius, 
				_center_z, 
				CollisionFlags.BODY, 
				CollisionLayers.ALL)
		
			if _raycast[RaycastData.HIT] {
				array_copy(wall_ray, 0, _raycast, 0, RaycastData.__SIZE)
			
				var _hit_y = _raycast[RaycastData.Y]
			
				y = _hit_y + (_hit_y < y ? radius : -radius)
				y_speed = 0
			}
		
			y += y_speed
		
			// Ceiling
			if raycast(x, y, z - _half_height, x, y, z + z_speed - height, CollisionFlags.BODY, CollisionLayers.ALL, ceiling_ray)[RaycastData.HIT] {
				z = ceiling_ray[RaycastData.Z] + height
				z_speed = 0
			}
		
			// Floor
			var _extra_z = 0
			
			if f_grounded {
				_extra_z += point_distance(0, 0, x_speed, y_speed)
			}
			
			if instance_exists(last_prop) {
				_extra_z += max(0, last_prop.z_speed) + 1 + clamp(z_speed, -1, 0)
				last_prop = noone
			}
			
			if raycast(x, y, z - _half_height, x, y, (z + z_speed) + _extra_z + math_get_epsilon(), CollisionFlags.BODY, CollisionLayers.ALL, floor_ray)[RaycastData.HIT] {
				z = floor_ray[RaycastData.Z]
				
				var _flags = floor_ray[RaycastData.TRIANGLE][TriangleData.FLAGS]
			
				if (_flags & CollisionFlags.STICKY) or (not (_flags & CollisionFlags.SLIPPERY) and abs(floor_ray[RaycastData.NZ]) >= 0.5) {
					z_speed = 0
					f_grounded = true
				
					// Stick to movers
					var _thing = floor_ray[RaycastData.THING]
				
					if instance_exists(_thing) and _ticking {
						if _thing.f_collider_stick {
							var _x, _y, _z, _x_speed, _y_speed, _yaw, _yaw_previous
							
							with _thing {
								_x = x
								_y = y
								_z = z
								_x_speed = x_speed
								_y_speed = y_speed
								_yaw = angle
								_yaw_previous = angle_previous
							}
							
							var _diff = angle_difference(_yaw, _yaw_previous)
							var _dir = point_direction(_x, _y, x, y) + _diff
							var _len = point_distance(x, y, _x, _y)
							
							x = _x + lengthdir_x(_len, _dir) + _x_speed
							y = _y + lengthdir_y(_len, _dir) + _y_speed
							
							if model != undefined {
								model.yaw += _diff
							}
							
							angle += _diff
							move_angle += _diff
						}
						
						with _thing {
							catspeak_execute(thing_on_prop, other)
						}
					}
					
					last_prop = _thing
				} else {
					var _dir = darctan2(-floor_ray[RaycastData.NY], floor_ray[RaycastData.NX])
					
					x += dcos(_dir)
					y -= dsin(_dir)
					f_grounded = false
				}
			} else {
				f_grounded = false
			}
			
			z += z_speed
			
			break
		}
	}
}

if _ticking {
	if tick != undefined {
		catspeak_execute(tick)
	}
	
	var _is_holding = instance_exists(holding) 
	
	if _is_holding {
		holding.x = x
		holding.y = y
		holding.z = z - height
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
		
		with _model {
			x = _x
			y = _y
			z = _z
			tick()
		}
		
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
}