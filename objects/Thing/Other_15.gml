/// @description Draw
var _draw_model = false
var _model

if not instance_exists(holder) or not f_holdable_in_hand {
	_model = model
	
	if _model != undefined {
		_draw_model = true
		_model.draw()
	
		if instance_exists(holding) and holding.f_holdable_in_hand {
			var _hold_bone = _model.hold_bone
			
			if _hold_bone != -1 {
				with holding {
					if model != undefined {
						with model {
							var _mwp = matrix_get(matrix_world)
							
							matrix_build_dq(_model.get_node_dq(_hold_bone), draw_matrix)
							
							var _hold_matrix = matrix_multiply(hold_offset_matrix, draw_matrix)
							
							draw_matrix = matrix_multiply(_hold_matrix, _model.draw_matrix)
							matrix_set(matrix_world, draw_matrix)
							submit()
							matrix_set(matrix_world, _mwp)
						}
					}
					
					if draw != undefined {
						catspeak_execute(draw)
					}
				}
			}
		}
	}
	
	if draw != undefined {
		catspeak_execute(draw)
	}
} else {
	_draw_model = false
}

if m_shadow != MShadow.NONE and shadow_ray[RaycastData.HIT] {
	if m_shadow == MShadow.MODEL {
		if _draw_model {
			var _mwp = matrix_get(matrix_world)
			var _shadow_ray = shadow_ray
			
			with _model {
				matrix_set(matrix_world, matrix_multiply(
					matrix_build(0, 0, 0, sroll, spitch, syaw, sscale * sx_scale, sscale * sy_scale, 0),
					matrix_build_normal(sx, sy, other.sshadow_z - 0.05, _shadow_ray[RaycastData.NX], _shadow_ray[RaycastData.NY], _shadow_ray[RaycastData.NZ], 1, other.shadow_matrix)
				))
				
				var _color = color
				var _alpha = alpha
				var _stencil_alpha = stencil_alpha
				
				color = c_black
				alpha = 0.5
				stencil_alpha = 0
				submit()
				color = _color
				alpha = _alpha
				stencil_alpha = _stencil_alpha
			}
			
			matrix_set(matrix_world, _mwp)
		}
	} else {
		var _radius = (shadow_radius ?? radius) * 2.285714285714286 // 2 * (32 / 28)
		
		batch_set_properties()
		batch_floor_ext(imgShadow, 0, _radius, _radius, sshadow_x, sshadow_y, sshadow_z - 0.0625, shadow_ray[RaycastData.NX], shadow_ray[RaycastData.NY], shadow_ray[RaycastData.NZ], c_black, 0.5)
	}
}