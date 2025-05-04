// Credit: JujuAdams
function Bloom(_width, _height, _max_iterations) constructor {
	width = _width
	height = _height
	max_iterations = _max_iterations
	
	var n = -~_max_iterations
	var i = 0
	
	surfaces = array_create(n)
	
	repeat n {
		var _struct = {
			width: _width,
			height: _height,
			surface: -1,
			texel_width: 1,
			texel_height: 1,
		}
		
		surfaces[i] = _struct
		check_surface(_struct)
		_width = _width div 2
		_height = _height div 2;
		++i
	}
	
	static resize = function (_width, _height) {
		var i = 0
		
		repeat -~max_iterations {
			with surfaces[i++] {
				width = _width
				height = _height
			}
			
			_width = _width div 2
			_height = _height div 2
		}
	}
	
	static blur = function (_iterations = max_iterations) {
		var i = 0
		
		repeat -~_iterations {
			if not surface_exists(check_surface(surfaces[i++])) {
				return false
			}
		}
		
		var _blendenable = gpu_get_blendenable()
		var _tex_filter = gpu_get_tex_filter()
		var _shader = shader_current()
		var _blendmode_src = gpu_get_blendmode_src()
		var _blendmode_dest = gpu_get_blendmode_dest()
		
		gpu_set_blendenable(true)
		gpu_set_tex_filter(true)
		gpu_set_blendmode_ext(bm_one, bm_zero)
		global.bloom_down_shader.set()
		i = 1
		
		var _u_texel = global.u_texel
		
		repeat _iterations {
			var _previous = surfaces[i - 1]
			var _next = surfaces[i]
			var _width, _height
			
			with _next {
				surface_set_target(surface)
				_width = width
				_height = height
			}
			
			with _previous {
				_u_texel.set(texel_width, texel_height)
				draw_surface_stretched(surface, 0, 0, _width, _height)
			}
			
			surface_reset_target();
			++i
		}
		
		global.bloom_up_shader.set()
		i = _iterations
		
		repeat _iterations {
			var _previous = surfaces[i]
			var _next = surfaces[i - 1]
			var _width, _height
			
			with _next {
				surface_set_target(surface)
				_width = width
				_height = height
			}
			
			with _previous {
				_u_texel.set(texel_width, texel_height)
				draw_surface_stretched(surface, 0, 0, _width, _height)
			}
			
			surface_reset_target();
			--i
		}
		
		gpu_set_blendenable(_blendenable)
		gpu_set_tex_filter(_tex_filter)
		shader_set(_shader)
		gpu_set_blendmode_ext(_blendmode_src, _blendmode_dest)
		
		return true
	}
	
	static check_surface = function (_struct) {
		var _width, _height, _surface
		
		with _struct {
			_width = max(width, 1)
			_height = max(height, 1)
			_surface = surface
		}
		
		var _update = false
		
		if not surface_exists(_surface) {
			var _depth = surface_get_depth_disable()
			
			surface_depth_disable(true)
			_surface = surface_create(_width, _height)
			surface_depth_disable(_depth)
			_update = true
		}
		
		if surface_get_width(_surface) != _width or surface_get_height(_surface) != _height {
			surface_resize(_surface, _width, _height)
			_update = true
		}
		
		if _update {
			var _texture = surface_get_texture(_surface)
			
			with _struct {
				surface = _surface
				texel_width = 0.5 * texture_get_texel_width(_texture)
				texel_height = 0.5 * texture_get_texel_height(_texture)
			}
		}
		
		return _surface
	}
	
	static get_surface = function () {
		gml_pragma("forceinline")
		
		return check_surface(surfaces[0])
	}
	
	static clear = function () {
		var i = 0
		
		repeat array_length(surfaces) {
			with surfaces[i++] {
				if surface_exists(surface) {
					surface_free(surface)
				}
			}
		}
	}
}