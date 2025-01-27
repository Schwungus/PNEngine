function ModelInstance(_model, _x = 0, _y = 0, _z = 0, _yaw = 0, _pitch = 0, _roll = 0, _scale = 1, _x_scale = 1, _y_scale = 1, _z_scale = 1) constructor {
	model = _model
	submodels = _model.submodels
	
	var n = array_length(submodels)
	var i = 0
	
	submodels_amount = n
	skins = array_create(n)
	
	repeat n {
		if submodels[i].hidden {
			skins[i] = -1
		}
		
		++i
	}
	
	skins_updated = true
	override_textures = array_create(n, undefined)
	cache = []
	cache_amount = 0
	
	head_bone = _model.head_bone
	torso_bone = _model.torso_bone
	hold_bone = _model.hold_bone
	
	hold_offset_matrix = _model.hold_offset_matrix
	points = _model.points
	
	static set_skin = function (_submodel, _skin) {
		gml_pragma("forceinline")
		
		if skins[_submodel] != _skin {
			skins[_submodel] = _skin
			skins_updated = true
		}
	}
	
	static override_texture = function (_submodel, _texture) {
		gml_pragma("forceinline")
		
		if override_textures[_submodel] != _texture {
			override_textures[_submodel] = _texture
			skins_updated = true
		}
	}
	
#region Animation
	animated = false
	animation_name = ""
	animation = undefined
	animation_main = undefined
	animation_loop = false
	animation_finished = false
	animation_state = 0
	animation_blend = 0
	frame = 0
	frame_speed = 1
	
	interp("frame", "sframe")
	
	transition = 0
	transition_duration = 0
	transition_frame = []
	transition_frame_old = []
	
	node_transforms = []
	node_post_rotations = undefined
	tick_sample = []
	from_sample = []
	draw_sample = []
	
	splice_name = ""
	splice = undefined
	splice_branch = undefined
	splice_loop = false
	splice_finished = false
	splice_state = 0
	splice_frame = 0
	splice_speed = 1
	
	sync_parent = undefined
	sync_child = undefined
	
	static output_to_sample = function (_sample) {
		static _transframe = []
		
		if is_array(animation) {
			static _blend_a = dq_build_identity()
			static _blend_b = dq_build_identity()
			
			var _blends = array_length(animation)
			var _anim_a = animation[animation_blend % _blends]
			var _anim_b = animation[(animation_blend + 1) % _blends]
			var _duration = _anim_a.duration
			var _frame, _next_frame
			
			if animation_loop {
				_frame = frame % _duration
				_next_frame = (frame + 1) % _duration
			} else {
				var _last_frame = _duration - 1
				
				_frame = min(frame, _last_frame)
				_next_frame = min(frame + 1, _last_frame)
			}
			
			var _parent_a = _anim_a.parent_frames
			var _parent_b = _anim_b.parent_frames
			var _frame_blend = frac(frame)
			
			dq_slerp_array(_parent_a[_frame], _parent_a[_next_frame], _frame_blend, _blend_a)
			dq_slerp_array(_parent_b[_frame], _parent_b[_next_frame], _frame_blend, _blend_b)
			dq_slerp_array(_blend_a, _blend_b, frac(animation_blend), _transframe)
		} else {
			var _duration = animation.duration
			var _frame, _next_frame
			
			if animation_loop {
				_frame = frame % _duration
				_next_frame = (frame + 1) % _duration
			} else {
				var _last_frame = _duration - 1
			
				_frame = min(frame, _last_frame)
				_next_frame = min(frame + 1, _last_frame)
			}
			
			var _parent_frames = animation.parent_frames
			
			dq_lerp_array(_parent_frames[_frame], _parent_frames[_next_frame], frac(frame), _transframe)
		}
		
		if not (splice == undefined or splice_branch == undefined) {
			var _parent_frames = splice.parent_frames
			var _duration = splice.duration
			var _splice_data = _parent_frames[splice_loop ? (splice_frame % _duration) : min(splice_frame, _duration - 1)]
			var i = 0
			
			repeat array_length(splice_branch) {
				var _offset = splice_branch[i++] * 8
				
				array_copy(_transframe, _offset, _splice_data, _offset, 8)
			}
		}
		
		if transition < transition_duration {
			dq_slerp_array(transition_frame, _transframe, transition / transition_duration, _transframe)
		}
		
		var _bone_offsets = model.bone_offsets
		var _node_count = model.nodes_amount
		var _root_node = model.root_node
		
		static _node_stack = []
		
		if array_length(_node_stack) < _node_count {
			array_resize(_node_stack, _node_count)
		}
		
		_node_stack[0] = _root_node
		
		var _stack_next = 1
		
		repeat _node_count {
			if _stack_next == 0 {
				break
			}
			
			var _node = _node_stack[--_stack_next]
			
			// TODO: Separate skeleton from the rest of the nodes to save on
			// iterations here.
			
			var _node_index = _node.index
			var _node_offset = _node_index * 8
			var _node_post_rotation = node_post_rotations[_node_index]
			var _node_parent = _node.parent
			var _parent_index = (_node_parent != undefined) ? _node_parent.index : -1
			
			if _node_post_rotation != undefined {
				static _npr_dq = new BBMOD_DualQuaternion()
				static _npr_dq_mul = new BBMOD_DualQuaternion()
				static _npr_q = new BBMOD_Quaternion()
				
				with _npr_dq {
					FromArray(_transframe, _node_offset)
					
					var _position = GetTranslation()
					var _rotation = GetRotation()
					
					_npr_q.FromArray(_node_post_rotation)
					
					if _node_post_rotation[4] {
						_rotation = _npr_q.MulSelf(_rotation)
					} else {
						_rotation.MulSelf(_npr_q)
					}
					
					FromTranslationRotation(_position, _rotation)
				}
				
				var _node_transforms = node_transforms
				
				with _npr_dq {
					if _parent_index != -1 {
						MulSelf(_npr_dq_mul.FromArray(_node_transforms, _parent_index * 8))
					}
					
					ToArray(_node_transforms, _node_offset)
				}
			} else {
				if _parent_index == -1 {
					// No parent transform -> just copy the node transform
					array_copy(node_transforms, _node_offset, _transframe, _node_offset, 8)
				} else {
					// Multiply node transform with parent's transform
					dq_multiply_array(_transframe, _node_offset, node_transforms, _parent_index * 8, node_transforms, _node_offset)
				}
			}
			
			if _node.is_bone {
				dq_multiply_array(_bone_offsets, _node_offset, node_transforms, _node_offset, _sample, _node_offset)
			}
			
			var _children = _node.children
			var i = 0
			
			repeat array_length(_children) {
				_node_stack[_stack_next++] = _children[i++]
			}
		}
		
		return _sample
	}
	
	static set_animation = function (_animation = undefined, _frame = 0, _loop = false, _time = 0, _blend = 0) {
		if _animation == undefined {
			animation_name = ""
			animation = undefined
			animation_main = undefined
			animation_loop = _loop
			animation_finished = false
			animation_state = 0
			animation_blend = 0
			
			if _frame >= 0 {
				frame = _frame
			}
			
			frame_speed = 1
			transition = 0
			transition_duration = 0
			
			exit
		}
		
		var _transitioning = false
		
		if _time > 0 and animation != undefined {
			if _time > 1 {
				var _was_transitioning = transition < transition_duration
				
				if _was_transitioning {
					array_copy(transition_frame_old, 0, transition_frame, 0, array_length(transition_frame))
				}
				
				var _duration, _transframe
				
				if is_array(animation) {
					static blend_parent_frame = dq_build_identity()
					
					var _blends = array_length(animation)
					var _anim_a = animation[animation_blend % _blends]
					var _anim_b = animation[(animation_blend + 1) % _blends]
					
					_duration = _anim_a.duration
					
					var _trans_at = animation_loop ? (frame % _duration) : min(frame, _duration - 1)
					
					_transframe = dq_slerp_array(_anim_a.parent_frames[_trans_at], _anim_b.parent_frames[_trans_at], frac(animation_blend), blend_parent_frame)
				} else {
					_duration = animation.duration
					_transframe = animation.parent_frames[animation_loop ? (frame % _duration) : min(frame, _duration - 1)]
				}
				
				array_copy(transition_frame, 0, _transframe, 0, array_length(_transframe))
				
				if not (splice == undefined or splice_branch == undefined) {
					var _parent_frames = splice.parent_frames
					
					_duration = splice.duration
					
					var _splice_data = _parent_frames[splice_loop ? (splice_frame % _duration) : min(splice_frame, _duration - 1)]
					var i = 0
					
					repeat array_length(splice_branch) {
						var _offset = splice_branch[i++] * 8
						
						array_copy(transition_frame, _offset, _splice_data, _offset, 8)
					}
				}
				
				if _was_transitioning {
					dq_slerp_array(transition_frame_old, transition_frame, transition / transition_duration, transition_frame)
				}
			}
			
			transition = 1
			_transitioning = true
		} else {
			transition = 0
		}
		
		transition_duration = _time
		animation = _animation 
		
		if is_array(_animation) {
			animation_main = _animation[0]
			animation_name = animation_main.name
		} else {
			animation_main = _animation
			animation_name = _animation.name
		}
		
		animation_loop = _loop
		animation_finished = false
		animation_state = 0
		animation_blend = _blend
		
		if _frame >= 0 {
			frame = _frame
			interp_skip("sframe")
		}
		
		frame_speed = 1
		
		if not animated {
			var n = model.nodes_amount
			
			node_post_rotations = array_create(n, undefined)
			node_scales = array_create(n, undefined)
			animated = true
		}
		
		if not _transitioning {
			output_to_sample(tick_sample)
			array_copy(from_sample, 0, tick_sample, 0, array_length(tick_sample))
		}
	}
	
	static set_splice_animation = function (_animation = undefined, _branch = undefined, _frame = 0, _loop = false) {
		if _frame < 0 and _animation != undefined {
			_frame = _animation.duration - 1
		}
		
		splice_name = _animation == undefined ? "" : _animation.name
		splice = _animation
		splice_branch = _branch
		splice_frame = _frame
		splice_loop = _loop
		splice_finished = false
		splice_state = 0
		splice_speed = 1
		output_to_sample(tick_sample)
		array_copy(from_sample, 0, tick_sample, 0, array_length(tick_sample))
		interp_skip("sframe")
	}
	
	static get_node = function (_id) {
		gml_pragma("forceinline")
		
		return model.get_node(_id)
	}
	
	static get_node_id = function (_id) {
		gml_pragma("forceinline")
		
		return model.get_node_id(_id)
	}
	
	static get_branch = function (_id) {
		gml_pragma("forceinline")
		
		return model.get_branch(_id)
	}
	
	static get_branch_id = function (_id) {
		gml_pragma("forceinline")
		
		return model.get_branch_id(_id)
	}
	
	static get_point = function (_name, _visual = false) {
		var _point = points[$ _name]
		var _x = _point[0]
		var _y = _point[1]
		var _z = _point[2]
		var _node = _point[3]
		
		if _node != undefined {
			var _node_pos = dq_transform_point(get_node_dq(_node.index), _x, _y, _z)
			
			_x = _node_pos[0]
			_y = _node_pos[1]
			_z = _node_pos[2]
		}
		
		return matrix_transform_point(_visual ? draw_matrix : tick_matrix, _x, _y, _z)
	}
	
	static get_node_dq = function (_index, _visual = false) {
		gml_pragma("forceinline")
		
		static node_dq = dq_build_identity()
		
		array_copy(node_dq, 0, node_transforms, _index * 8, 8)
		
		return node_dq
	}
	
	static get_node_pos = function (_index, _visual = false) {
		gml_pragma("forceinline")
		
		var _pos = dq_get_translation(get_node_dq(_index))
		
		return matrix_transform_point(_visual ? draw_matrix : tick_matrix, _pos[0], _pos[1], _pos[2])
	}
	
	static post_rotate_node = function (_index, _x, _y, _z, _global = false) {
		var _quat = node_post_rotations[_index]
		
		if _quat == undefined {
			_quat = quat_build()
			node_post_rotations[_index] = _quat
		}
		
		quat_build_euler(_x, _y, _z, _quat)
		_quat[4] = _global
		
		return _quat
	}
	
	static post_rotate_node_quat = function (_index, _quat, _global = false) {
		gml_pragma("forceinline")
		
		node_post_rotations[_index] = _quat
		_quat[4] = _global
		
		return _quat
	}
	
	static force_tick = function (_update_matrix) {
		gml_pragma("forceinline")
		
		var _update_sample = false
		
		if animation_main != undefined {
			var _frame_step = frame_speed * animation_main.frame_speed
			
			animation_finished = false
			
			if animation_loop {
				// Looping animation
				frame += _frame_step
			} else {
				// Animation plays only once
				var _frames = animation_main.duration - 1
				
				frame = clamp(frame + _frame_step, 0, _frames)
				animation_finished = frame >= _frames
			}
			
			_update_sample = true
		}
		
		if splice != undefined {
			var _frame_step = splice_speed * splice.frame_speed
			
			splice_frame += _frame_step
			splice_finished = false
			
			if not splice_loop and splice_frame >= (splice.duration - 1) {
				splice_finished = true
			} else {
				_update_sample = true
			}
		}
		
		if transition < transition_duration {
			++transition
			_update_sample = true
		}
		
		if _update_sample {
			array_copy(from_sample, 0, tick_sample, 0, array_length(tick_sample))
			output_to_sample(tick_sample)
		}
		
		if _update_matrix {
			tick_matrix = matrix_build(x, y, z, roll, pitch, yaw, scale * x_scale, scale * y_scale, scale * z_scale)
		}
		
		if sync_child != undefined {
			sync_child.force_tick(_update_matrix)
		}
	}
	
	static tick = function (_update_matrix = true) {
		if sync_parent != undefined {
			return
		}
		
		force_tick(_update_matrix)
	}
	
	static sync_with = function (_model) {
		if sync_child != undefined {
			sync_child.sync_parent = undefined
		}
		
		sync_child = _model
		
		if _model != undefined {
			with _model {
				if sync_parent != undefined {
					sync_parent.sync_child = undefined
				}
				
				sync_parent = other
			}
		}
	}
#endregion
	
#region Transform
	tick_matrix = matrix_build(_x, _y, _z, _roll, _pitch, _yaw, _scale * _x_scale, _scale * _y_scale, _scale * _z_scale)
	draw_matrix = matrix_build(_x, _y, _z, _roll, _pitch, _yaw, _scale * _x_scale, _scale * _y_scale, _scale * _z_scale)
	
	x = _x
	y = _y
	z = _z
	
	yaw = _yaw
	pitch = _pitch
	roll = _roll
	
	scale = _scale
	x_scale = _x_scale
	y_scale = _y_scale
	z_scale = _z_scale
	
	interp("x", "sx")
	interp("y", "sy")
	interp("z", "sz")
	
	interp("yaw", "syaw", true)
	interp("pitch", "spitch", true)
	interp("roll", "sroll", true)
	
	interp("scale", "sscale")
	interp("x_scale", "sx_scale")
	interp("y_scale", "sy_scale")
	interp("z_scale", "sz_scale")
	
	static move = function (_x, _y, _z) {
		x = _x
		y = _y
		z = _z
		interp_skip("sx")
		interp_skip("sy")
		interp_skip("sz")
		
		return self
	}
	
	static rotate = function (_yaw, _pitch, _roll) {
		yaw = _yaw
		pitch = _pitch
		roll = _roll
		interp_skip("syaw")
		interp_skip("spitch")
		interp_skip("sroll")
		
		return self
	}
	
	static resize = function (_scale, _x_scale = x_scale, _y_scale = y_scale, _z_scale = z_scale) {
		scale = _scale
		x_scale = _x_scale
		y_scale = _y_scale
		z_scale = _z_scale
		interp_skip("sscale")
		interp_skip("sx_scale")
		interp_skip("sy_scale")
		interp_skip("sz_scale")
		
		return self
	}
#endregion
	
#region Rendering
	visible = true
	color = c_white
	blendmode = bm_normal
	alpha = 1
	stencil = c_white
	stencil_alpha = 0
	
	static submit = function () {
		var _blendmode = gpu_get_blendmode()
		
		global.u_color.set(color_get_red(color) * COLOR_INVERSE, color_get_green(color) * COLOR_INVERSE, color_get_blue(color) * COLOR_INVERSE, alpha)
		global.u_stencil.set(color_get_red(stencil) * COLOR_INVERSE, color_get_green(stencil) * COLOR_INVERSE, color_get_blue(stencil) * COLOR_INVERSE, stencil_alpha)
		
		if shader_current() == shSky and blendmode == bm_normal {
			gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_src_alpha, bm_one)
		} else {
			gpu_set_blendmode(blendmode)
		}
		
		if animation_main == undefined {
			global.u_animated.set(0)
		} else {
			global.u_animated.set(1)
			
			if sframe == frame {
				array_copy(draw_sample, 0, tick_sample, 0, array_length(tick_sample))
			} else {
				dq_lerp_array(from_sample, tick_sample, global.tick, draw_sample)
			}
			
			global.u_bone_dq.set(draw_sample)
		}
		
		var _u_material_bright = global.u_material_bright
		var _u_material_specular = global.u_material_specular
		var _u_material_rimlight = global.u_material_rimlight
		var _u_material_wind = global.u_material_wind
		var _u_material_color = global.u_material_color
		var _u_material_alpha_test = global.u_material_alpha_test
		var _u_material_scroll = global.u_material_scroll
		var _u_material_can_blend = global.u_material_can_blend
		var _u_material_blend = global.u_material_blend
		var _u_material_blend_uvs = global.u_material_blend_uvs
		var _u_uvs = global.u_uvs
		var _u_texture_size = global.u_texture_size
		var _u_max_lod = global.u_max_lod
		var _u_mipmaps = global.u_mipmaps
		var _lightmap = model.lightmap
		
		if _lightmap != undefined {
			global.u_lightmap_enable_vertex.set(true)
			global.u_lightmap_enable_pixel.set(true)
			global.u_lightmap.set(_lightmap.GetTexture(0))
			
			var _uvs = _lightmap.GetUVs(0)
			
			with _uvs {
				global.u_lightmap_uvs.set(normLeft, normTop, normRight, normBottom)
			}
		} else {
			global.u_lightmap_enable_vertex.set(false)
			global.u_lightmap_enable_pixel.set(false)
		}
		
		if skins_updated {
			var i = 0
			var j = 0
			var k = 0
			var _cache = cache
			var _override_textures = override_textures
			
			repeat submodels_amount {
				var _skin = skins[i]
				
				if _skin == -1 {
					++i
					
					continue
				}
				
				with submodels[i] {
					_cache[j] = vbo
					
					var _material = materials[_skin]
					
					_cache[-~j] = _material
					
					var _texture = _override_textures[i]
					
					if not CollageIsImage(_texture) and not CanvasIsCanvas(_texture) {
						_texture = _material.image
					}
					
					_cache[j + 2] = _texture
				}
				
				++i
				j += 3;
				++k
			}
			
			array_resize(_cache, j)
			cache_amount = k
			skins_updated = false
		}
		
		var i = 0
		
		repeat cache_amount {
			var _vbo = cache[i]
			var _material = cache[-~i]
			var _texture = cache[i + 2]
			var _idx = _material.frame_speed * current_time
			
			with _material {
				if CollageIsImage(image2) {
					_u_material_can_blend.set(1)
					
					if image2 == -1 {
						_u_material_blend.set(-1)
					} else {
						_u_material_blend.set(image2.GetTexture(_idx))
						
						var _uvs = image2.GetUVs(_idx)
						
						with _uvs {
							_u_material_blend_uvs.set(normLeft, normTop, normRight, normBottom)
						}
					}
				} else {
					_u_material_can_blend.set(0)
				}
				
				_u_material_bright.set(bright)
				_u_material_specular.set(specular, specular_exponent)
				_u_material_rimlight.set(rimlight, rimlight_exponent)
				_u_material_wind.set(wind, wind_lock_bottom, wind_speed)
				_u_material_color.set(color[0], color[1], color[2], color[3])
			}
			
			with _material {
				_u_material_alpha_test.set(alpha_test)
				_u_material_scroll.set(x_scroll, y_scroll)
			}
			
			if CollageIsImage(_texture) {
				with _texture {
					with GetUVs(_idx) {
						_u_uvs.set(normLeft, normTop, normRight, normBottom)
					}
					
					_u_texture_size.set(GetWidth(), GetHeight())
					_u_max_lod.set(__maxLOD)
					_u_mipmaps.set(__mipmaps[_idx % GetCount()])
					_texture = GetTexture(_idx)
				}
			} else if CanvasIsCanvas(_texture) {
				_u_uvs.set(0, 0, 1, 1)
				_u_max_lod.set(0)
				
				with _texture {
					_u_texture_size.set(GetWidth(), GetHeight())
					_u_mipmaps.set(global.blank_mipmap)
					_texture = GetTexture()
				}
			}
			
			vertex_submit(_vbo, pr_trianglelist, _texture)
			i += 3
		}
		
		gpu_set_blendmode(_blendmode)
	}
	
	static draw = function () {
		var _mwp = matrix_get(matrix_world)
		
		draw_matrix = matrix_build(sx, sy, sz, sroll, spitch, syaw, sscale * sx_scale, sscale * sy_scale, sscale * sz_scale)
		matrix_set(matrix_world, draw_matrix)
		submit()
		matrix_set(matrix_world, _mwp)
	}
#endregion
}