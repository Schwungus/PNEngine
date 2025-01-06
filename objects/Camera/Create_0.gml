#macro SKY_SCROLL_FACTOR -0.3515625

enum CameraTargetData {
	RANGE,
	X_OFFSET,
	Y_OFFSET,
	Z_OFFSET,
	__SIZE,
}

enum CameraPOIData {
	LERP,
	X_OFFSET,
	Y_OFFSET,
	Z_OFFSET,
}

enum CameraPathData {
	TIME,
	X,
	Y,
	Z,
	YAW,
	PITCH,
	ROLL,
	FOV,
	__SIZE,
}

enum CameraLerpTypes {
	LINEAR,
	SMOOTH,
	EASE_IN,
	EASE_OUT,
}

event_inherited()

#region Variables
radius = 1
height = 1

yaw = 0
roll = 0
fov = 45

interp("yaw", "syaw", true)
interp("pitch", "spitch", true)
interp("roll", "sroll", true)
interp("fov", "sfov")

range = 0
range_lerp = 0.25
targets = ds_map_create()
pois = ds_map_create()
child = noone
parent = noone
f_raycast = true

forward_axis = matrix_build(1, 0, 0, 0, 0, 0, 1, 1, 1)
up_axis = matrix_build(0, 0, -1, 0, 0, 0, 1, 1, 1)
view_matrix = undefined
projection_matrix = undefined
f_ortho = false

path = ds_grid_create(0, CameraPathData.__SIZE)
path_elapsed = 0
path_time = 0
path_quadratic = false
path_loop = false
path_active = false

lerp_x = 0
lerp_y = 0
lerp_z = 0
lerp_yaw = 0
lerp_pitch = 0
lerp_roll = 0
lerp_fov = 0
lerp_time = 0
lerp_duration = 0
lerp_type = false

quake = 0
quake_x = 0
quake_y = 0
quake_z = 0

interp("quake_x", "squake_x")
interp("quake_y", "squake_y")
interp("quake_z", "squake_z")

alpha = 1
output = (new Canvas(1, 1)).SetDepthDisabled(true)

listener_pos = new FmodVector()
listener_vel = new FmodVector()
listener_rot = new FmodVector()
listener_up = new FmodVector()

with listener_up {
	x = 0
	y = 0
	z = 1
}
#endregion

#region Functions
resolve = function () {
	var _camera_active = global.camera_active
	
	if thing_exists(_camera_active) and _camera_active.area == area {
		return _camera_active
	}
	
	if thing_exists(child) {
		return child.resolve()
	}
	
	return self
}

add_target = function (_target, _range = 100, _x_offset = 0, _y_offset = 0, _z_offset = 0) {
	var _target_data = [_range, _x_offset, _y_offset, _z_offset]
		
	ds_map_add(targets, _target, _target_data)
		
	return _target_data
}

delete_target = function (_target) {
	if _target == all {
		ds_map_clear(targets)
	} else {
		ds_map_delete(targets, _target)
	}
}

add_poi = function (_target, _lerp = 1, _x_offset = 0, _y_offset = 0, _z_offset = 0) {
	var _poi_data = [_lerp, _x_offset, _y_offset, _z_offset]
	
	ds_map_add(pois, _target, _poi_data)
	
	return _poi_data
}

delete_poi = function (_target) {
	if _target == all {
		ds_map_clear(pois)
	} else {
		ds_map_delete(pois, _target)
	}
}

add_path = function (_time, _x, _y, _z, _yaw, _pitch, _roll, _fov) {
	gml_pragma("forceinline")
	
	var i = ds_grid_width(path)
	
	ds_grid_resize(path, -~i, CameraPathData.__SIZE)
	path[# i, CameraPathData.TIME] = _time
	path[# i, CameraPathData.X] = _x
	path[# i, CameraPathData.Y] = _y
	path[# i, CameraPathData.Z] = _z
	path[# i, CameraPathData.YAW] = _yaw
	path[# i, CameraPathData.PITCH] = _pitch
	path[# i, CameraPathData.ROLL] = _roll
	path[# i, CameraPathData.FOV] = _fov
}

clear_path = function () {
	ds_grid_resize(path, 0, CameraPathData.__SIZE)
	stop_path()
}

start_path = function (_time, _quadratic = false, _loop = false) {
	if ds_grid_width(path) == 0 {
		return false
	}
	
	path_elapsed = 0
	path_time = _time
	path_quadratic = _quadratic
	path_loop = _loop
	path_active = true
	
	set_position(path[# 0, CameraPathData.X], path[# 0, CameraPathData.Y], path[# 0, CameraPathData.Z], true)
	yaw = path[# 0, CameraPathData.YAW]
	pitch = path[# 0, CameraPathData.PITCH]
	roll = path[# 0, CameraPathData.ROLL]
	fov = path[# 0, CameraPathData.FOV]
	interp_skip("syaw")
	interp_skip("spitch")
	interp_skip("sroll")
	interp_skip("sfov")
	
	return true
}

stop_path = function () {
	path_active = false
}

lerp_from_self = function (_time, _type = CameraLerpTypes.LINEAR) {
	lerp_x = sx
	lerp_y = sy
	lerp_z = sz
	lerp_yaw = syaw
	lerp_pitch = spitch
	lerp_roll = sroll
	lerp_fov = sfov
	lerp_time = 0
	lerp_duration = _time
	lerp_type = _type
}

lerp_from = function (_camera, _time, _type = CameraLerpTypes.LINEAR) {
	lerp_x = _camera.sx
	lerp_y = _camera.sy
	lerp_z = _camera.sz
	lerp_yaw = _camera.syaw
	lerp_pitch = _camera.spitch
	lerp_roll = _camera.sroll
	lerp_fov = _camera.sfov
	lerp_time = 0
	lerp_duration = _time
	lerp_type = _type
}
	
set_child = function (_camera) {
	if thing_exists(child) {
		child.parent = noone
	}
	
	child = _camera
	
	if thing_exists(_camera) {
		_camera.parent = self
	}
}

set_active = function (_bool) {
	if _bool {
		global.camera_active = self
		
		return true
	} else {
		if global.camera_active == self {
			global.camera_active = noone
			
			return true
		}
	}
	
	return false
}

update_matrices = function (_width = window_get_width(), _height = window_get_height(), _update_listener = false) {
	var _matrix = matrix_build(0, 0, 0, sroll, spitch, syaw, 1, 1, 1)
	
	var _forward = matrix_multiply(forward_axis, _matrix)
	var _fx = _forward[12]
	var _fy = _forward[13]
	var _fz = _forward[14]
	
	var _up = matrix_multiply(up_axis, _matrix)
	var _ux = _up[12]
	var _uy = _up[13]
	var _uz = _up[14]
	
	view_matrix = matrix_build_lookat(sx, sy, sz, sx + _fx, sy + _fy, sz + _fz, _ux, _uy, _uz)
	projection_matrix = f_ortho ? matrix_build_projection_ortho(_width * 0.5, _height * 0.5, 1, 32000) : matrix_build_projection_perspective_fov(-sfov, -(_width / _height), 1, 32000)
	
	if _update_listener {
		listener_pos.x = sx
		listener_pos.y = sy
		listener_pos.z = sz
		
		with listener_rot {
			x = _fx
			y = _fy
			z = _fz
		}
		
		with listener_up {
			x = _ux
			y = _uy
			z = _uz
		}
		
		// TODO: Implement multiple listeners for splitscreen
		fmod_system_set_3d_listener_attributes(0, listener_pos, listener_vel, listener_rot, listener_up)
	}
}

world_to_screen = function (_x, _y, _z) {
	static _pos = array_create(2)
	
	var _w = view_matrix[2] * _x + view_matrix[6] * _y + view_matrix[10] * _z + view_matrix[14]
	
	if _w <= 0 {
		return undefined
	}
	
	var _w_inv = 1 / _w
	var _cx = projection_matrix[8] + projection_matrix[0] * (view_matrix[0] * _x + view_matrix[4] * _y + view_matrix[8] * _z + view_matrix[12]) * _w_inv
	var _cy = projection_matrix[9] + projection_matrix[5] * (view_matrix[1] * _x + view_matrix[5] * _y + view_matrix[9] * _z + view_matrix[13]) * _w_inv
	
	_pos[0] = 0.5 + 0.5 * _cx
	_pos[1] = 0.5 + 0.5 * _cy
	
	return _pos
}

depth_from_world = function (_x, _y) {
	var _canvases = global.canvases
	var _surface = _canvases[Canvases.WORLD].GetSurfaceID()
	
	if not surface_exists(_surface) {
		return 0
	}
	
	var _width = surface_get_width(_surface)
	var _height = surface_get_height(_surface)
	var _depth_canvas = _canvases[Canvases.DEPTH]
	
	with _depth_canvas {
		Resize(_width, _height)
		Start()
		draw_primitive_begin_texture(pr_trianglestrip, surface_get_texture_depth(_surface))
		draw_vertex_texture(0, _height, 0, 1)
		draw_vertex_texture(_width, _height, 1, 1)
		draw_vertex_texture(0, 0, 0, 0)
		draw_vertex_texture(_width, 0, 1, 0)
		draw_primitive_end()
		Finish()
		UpdateCache()
	}
	
	return _depth_canvas.GetPixel(floor(_x), floor(_y))
}

render = function (_width, _height, _update_listener = false, _allow_sky = true, _allow_screen = true, _world_shader = undefined) {
	++global.camera_layer
	
	if global.camera_layer == 1 {
		gpu_set_cullmode(cull_counterclockwise)
	}
	
	var _config = global.config
	
	_world_shader ??= (_config.vid_lighting.value or _config.vid_antialias.value) ? global.world_pixel_shader : global.world_shader
	
	if thing_exists(child) {
		var _render = child.render(_width, _height, _update_listener, _allow_sky, _allow_screen, _world_shader);
		
		--global.camera_layer
		
		if global.camera_layer <= 0 {
			gpu_set_cullmode(cull_noculling)
		}
		
		return _render
	}
	
	output.Resize(_width, _height)
	
	if lerp_time < lerp_duration {
		var _factor = lerp_time / lerp_duration
		
		switch lerp_type {
			case CameraLerpTypes.SMOOTH: _factor = lerp(sqr(_factor), 1 - sqr(1 - _factor), _factor) break
			case CameraLerpTypes.EASE_IN: _factor = sqr(_factor) break
			case CameraLerpTypes.EASE_OUT: _factor = 1 - sqr(1 - _factor) break
		}
		
		sx = lerp(lerp_x, sx, _factor)
		sy = lerp(lerp_y, sy, _factor)
		sz = lerp(lerp_z, sz, _factor)
		syaw = lerp_angle(lerp_yaw, syaw, _factor)
		spitch = lerp_angle(lerp_pitch, spitch, _factor)
		sroll = lerp_angle(lerp_roll, sroll, _factor)
		sfov = lerp(lerp_fov, sfov, _factor)
		lerp_time += global.delta
	}
	
	sx += squake_x
	sy += squake_y
	sz += squake_z
	
	var _x = sx
	var _y = sy
	var _z = sz
	
	var _area = area
	
	output.Start()
	
	var _canvases = global.canvases
	var _render_canvas = _canvases[Canvases.RENDER]
	
	_render_canvas.Resize(_width, _height)
	_render_canvas.Start()
	
	var _world_canvas = _canvases[Canvases.WORLD]
	
	_world_canvas.Resize(_width, _height)
	_world_canvas.Start()
	update_matrices(_width, _height, _update_listener)
	
	var _camera = camera_get_active()
	
	camera_set_view_mat(_camera, view_matrix)
	camera_set_proj_mat(_camera, projection_matrix)
	camera_apply(_camera)
	
	var _time = current_time * 0.001
	var _gpu_tex_filter = gpu_get_tex_filter()
	
	gpu_set_tex_filter(_config.vid_texture_filter.value)
	global.batch_camera = self
	
	var _active_things, _thing_count
	var _sky = noone
	
	with _area {
		if _allow_sky {
			draw_clear_alpha(clear_color[4], clear_color[3])
			
			if thing_exists(sky) and sky.model != undefined {
				_sky = sky
				gpu_set_zwriteenable(false)
				global.sky_shader.set()
				global.u_time.set(_time)
				
				with sky {
					model.sx = _x
					model.sy = _y
					model.sz = _z
					event_user(ThingEvents.DRAW)
				}
				
				batch_submit()
				gpu_set_zwriteenable(true)
			}
		} else {
			draw_clear(c_black)
		}
		
		_world_shader.set()
		global.u_ambient_color.set(ambient_color[0], ambient_color[1], ambient_color[2], ambient_color[3])
		global.u_fog_distance.set(fog_distance[0], fog_distance[1])
		global.u_fog_color.set(fog_color[0], fog_color[1], fog_color[2], fog_color[3])
		global.u_wind.set(wind_strength, wind_direction[0], wind_direction[1], wind_direction[2])
		global.u_light_data.set(light_data)
		global.u_time.set(_time)
		global.u_mipmap_filter.set(_config.vid_mipmap_filter.value)
		
		if model != undefined {
			model.draw()
		}
		
		_active_things = active_things
		
		var i = ds_list_size(_active_things)
		
		while i {
			with _active_things[| --i] {
				if f_visible and point_distance(_x, _y, sx, sy) < cull_draw {
					event_user(ThingEvents.DRAW)
				}
			}
		}
		
		i = 0
		
		repeat ds_list_size(particles) {
			var p = particles[| i++]
			
			batch_set_properties(p[ParticleData.ALPHA_TEST], p[ParticleData.BRIGHT], p[ParticleData.BLENDMODE], p[ParticleData.FILTER])
			
			var _pimage = p[ParticleData.IMAGE]
			var _pframe = p[ParticleData.FRAME]
			var _pwidth = p[ParticleData.WIDTH]
			var _pheight = p[ParticleData.HEIGHT]
			var _px = p[ParticleData.X]
			var _py = p[ParticleData.Y]
			var _pz = p[ParticleData.Z]
			var _pangle = p[ParticleData.ANGLE]
			var _pcolor = p[ParticleData.COLOR]
			var _palpha = p[ParticleData.ALPHA]
			
			if p[ParticleData.FLAT] {
				batch_floor_angle(_pimage, _pframe, _pwidth, _pheight, _px, _py, _pz, _pangle, p[ParticleData.PITCH], p[ParticleData.ROLL], _pcolor, _palpha)
			} else {
				batch_billboard(_pimage, _pframe, _pwidth, _pheight, _px, _py, _pz, _pangle, _pcolor, _palpha)
			}
		}
		
		batch_submit()
		gpu_set_tex_filter(_gpu_tex_filter)
		shader_reset()
		_world_canvas.Finish()
	}
	
	gpu_set_blendenable(false)
	_world_canvas.Draw(0, 0)
	gpu_set_blendenable(true)
	_render_canvas.Finish()
	
	if not _allow_screen or alpha >= 1 {
		gpu_set_blendenable(false)
		_render_canvas.Draw(0, 0)
		gpu_set_blendenable(true)
	} else {
		gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_src_alpha, bm_one)
		_render_canvas.DrawExt(0, 0, 1, 1, 0, c_white, clamp(global.delta * alpha, 0, 1))
		gpu_set_blendmode(bm_normal)
	}
	
	if _allow_screen {
		gpu_set_cullmode(cull_noculling)
		
		// Bloom
		if _config.vid_bloom.value {
			gpu_set_blendenable(false)
			global.bloom_pass_shader.set()
			global.u_threshold.set(0.85)
			global.u_intensity.set(0.36)
			
			var _bloom = global.bloom
			var _third_width = _width div 3
			var _third_height = _height div 3
			
			_bloom.resize(_third_width, _third_height)
			
			var _surface = _bloom.get_surface()
			
			surface_set_target(_surface)
			gpu_set_tex_filter(true)
			_render_canvas.DrawStretched(0, 0, _third_width, _third_height)
			surface_reset_target()
			shader_reset()
			_bloom.blur()
			gpu_set_blendenable(true)
			gpu_set_blendmode(bm_add)
			draw_surface_stretched_ext(_surface, 0, 0, _width, _height, c_white, alpha >= 1 ? 1 : clamp(global.delta * alpha, 0, 1))
			gpu_set_tex_filter(false)
			gpu_set_blendmode(bm_normal)
		}
		
		// HUD
		var i = ds_list_size(_active_things)
		var _gui_priority = global.gui_priority
		
		while i {
			with _active_things[| --i] {
				if f_visible or (_allow_sky and self == _sky) {
					ds_priority_add(_gui_priority, self, screen_depth)
				}
			}
		}
		
		repeat ds_priority_size(_gui_priority) {
			with ds_priority_delete_max(_gui_priority) {
				screen_camera = other
				screen_width = _width
				screen_height = _height
				event_user(ThingEvents.DRAW_SCREEN)
			}
		}
		
		gpu_set_cullmode(cull_counterclockwise)
	}
	
	output.Finish();
	--global.camera_layer
	
	if global.camera_layer <= 0 {
		gpu_set_cullmode(cull_noculling)
	}
	
	return output
}
#endregion