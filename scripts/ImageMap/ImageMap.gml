function ImageMap() : AssetMap() constructor {
	queue = ds_map_create()
	collage = new Collage()
	batch = false
	
	static start_batch = function () {
		gml_pragma("forceinline")
		
		batch = true
	}
	
	static end_batch = function () {
		gml_pragma("forceinline")
		
		if batch {
			post_batch()
		}
		
		batch = false
	}
	
	static post_batch = function () {
		// 1. Collage batch
		collage.StartBatch()
		
		var _key = ds_map_find_first(queue)
		
		repeat ds_map_size(queue) {
			var _image = queue[? _key]
			
			_image.original = collage.AddFile(
				_image.name,
				_key + ":default",
				_image.frames,
				false,
				false,
				_image.x_offset,
				_image.y_offset
			).SetPremultiplyAlpha(
				false
			).SetTiling(
				_image.x_repeat,
				_image.y_repeat
			).SetClump(
				true
			)
			
			_key = ds_map_find_next(queue, _key)
		}
		
		collage.FinishBatch()
		
		// 2. Palettes
		collage.StartBatch()
		_key = ds_map_find_first(queue)
		
		repeat ds_map_size(queue) {
			var _image = queue[? _key]
			var _name, _frames, _x_offset, _y_offset, _x_repeat, _y_repeat
			
			with _image {
				_name = name
				_frames = frames
				_x_offset = x_offset
				_y_offset = y_offset
				_x_repeat = x_repeat
				_y_repeat = y_repeat
			}
			
			var _variants = _image.variants
			var _vkey = ds_map_find_first(_variants)
			
			repeat ds_map_size(_variants) {
				var _pal = _variants[? _vkey]
				
				if is_array(_pal) {
					var _base = CollageImageGetInfo(_key + ":default")
					var _depth_disable = surface_get_depth_disable()
					
					surface_depth_disable(true)
					
					var _width = _base.GetWidth()
					var _height = _base.GetHeight()
					var _surface = surface_create(_width, _height)
					
					surface_set_target(_surface)
					//CollageSterlizeGPUState()
					draw_clear_alpha(c_black, 0)
					global.palette_shader.set()
					global.u_old.set(_pal[0])
					global.u_new.set(_pal[1])
					CollageDrawImageStretched(_base, 0, 0, 0, _width, _height)
					shader_reset()
					//CollageRestoreGPUState()
					surface_reset_target()
					
					collage.AddSurface(
						_surface,
						_key + ":" + _vkey,
						0,
						0,
						_width,
						_height,
						false,
						false,
						_x_offset,
						_y_offset
					).SetPremultiplyAlpha(
						false
					).SetTiling(
						_x_repeat,
						_y_repeat
					).SetClump(
						true
					)
					
					surface_free(_surface)
					surface_depth_disable(_depth_disable)
				}
				
				_vkey = ds_map_find_next(_variants, _vkey)
			}
			
			_key = ds_map_find_next(queue, _key)
		}
		
		collage.FinishBatch()
		
		// 3. Dequeue to assets
		repeat ds_map_size(queue) {
			_key = ds_map_find_first(queue)
			
			var _image = queue[? _key]
			
			_image.name = _key
			
			var _variants = _image.variants
			var _vkey = ds_map_find_first(_variants)
			var _frames = _image.frames
			
			repeat ds_map_size(_variants) {
				var _ikey = _key + ":" + _vkey
				var _variant = CollageImageGetInfo(_ikey)
				var _mipmaps = []
				var j = 0
				
				repeat _frames {
					var _submips
					
					if array_length(_mipmaps) <= j {
						_submips = array_create(4, 0)
						_mipmaps[j] = _submips
					} else {
						_submips = _mipmaps[j]
					}
					
					with _variant.GetUVs(j) {
						_submips[0] = normLeft
						_submips[1] = normTop
						_submips[2] = normRight
						_submips[3] = normBottom
					}
					
					++j
				}
				
				_variant.__mipmaps = _mipmaps
				_variant.__maxLOD = 0
				_variants[? _vkey] = _variant
				_vkey = ds_map_find_next(_variants, _vkey)
			}
			
			ds_map_add(assets, _key, _image)
			ds_map_delete(queue, _key)
		}
		
		var _materials = global.materials
		var _mtlq = _materials.queue
		
		repeat ds_map_size(_mtlq) {
			_key = ds_map_find_first(_mtlq)
			
			var _material = _mtlq[? _key]
			var _image = _material.image
			var _image2 = _material.image2
			
			if is_string(_image) {
				_material.image = get(_image)
			}
			
			if is_string(_image2) {
				_material.image2 = get(_image2)
			}
			
			ds_map_delete(_mtlq, _key)
		}
		
		var _models = global.models
		var _mdlq = _models.queue
		
		repeat ds_map_size(_mdlq) {
			_key = ds_map_find_first(_mdlq)
			
			var _model = _mdlq[? _key]
			var _lightmap = _model.lightmap
			
			if is_string(_lightmap) {
				_model.lightmap = get(_lightmap)
			}
			
			ds_map_delete(_mdlq, _key)
		}
	}
	
	static load = function (_name, _palette = "default") {
		var _image = queue[? _name] ?? assets[? _name]
		
		if _image == undefined {
			var _path = "images/" + _name
			var _png_file = mod_find_file(_path + ".*", ".json")
			
			if _png_file == "" {
				print($"! ImageMap.load: '{_name}' not found")
				
				return undefined
			}
			
			var _frames = 1
			var _x_offset = 0
			var _y_offset = 0
			var _x_repeat = true
			var _y_repeat = true
			var _mipmaps = undefined
			var _json = json_load(mod_find_file(_path + ".json"))
			
			if is_struct(_json) {
				_frames = force_type_fallback(_json[$ "frames"], "number", 1)
				_x_offset = force_type_fallback(_json[$ "x_offset"], "number", 0)
				_y_offset = force_type_fallback(_json[$ "y_offset"], "number", 0)
				_x_repeat = force_type_fallback(_json[$ "x_repeat"], "bool", true)
				_y_repeat = force_type_fallback(_json[$ "y_repeat"], "bool", true)
				_mipmaps = force_type_fallback(_json[$ "mipmaps"], "array")
			}
			
			_image = new Image()
			
			with _image {
				name = _png_file
				frames = _frames
				x_offset = _x_offset
				y_offset = _y_offset
				x_repeat = _x_repeat
				y_repeat = _y_repeat
				mipmaps = _mipmaps
			}
			
			ds_map_add(queue, _name, _image)
			print($"ImageMap.load: Added '{_name}' to queue")
			
			/*if _mipmaps != undefined {
				var i = 0
				
				repeat array_length(_mipmaps) {
					var _mname = _mipmaps[i]
					
					if _mname == _name {
						show_error("!!! ImageMap.load: YOU THOUGHT YOU COULD GET AWAY WITH THIS DIDN'T YOU", true)
					}
					
					var _mip = load(_mname, _palette)
					
					if _mip == undefined {
						show_error($"!!! ImageMap.load: Image '{_name}' has invalid LOD '{_mname}'", true)
					}
					
					_mipmaps[i++] = _mip
				}
			}*/
		}
		
		var _variants = _image.variants
		
		if not ds_map_exists(_variants, _palette) {
			var _pal = undefined
			
			if _palette != "default" {
				var _pal_file = mod_find_file("palettes/" + _palette + ".json")
				
				if _pal_file != "" {
					// Always load default palette first so we can get the
					// original image.
					load(_name)
					_pal = force_type(json_load(_pal_file), "array")
					
					var _old = _pal[0]
					var _new = _pal[1]
					var n = array_length(_old)
					var _n_vecs = n * 3
					
					var _old2 = array_create(_n_vecs, 0)
					var _new2 = array_create(_n_vecs, 0)
					var i = 0
					var j = 0
					
					repeat n {
						var j1 = -~j
						var j2 = j + 2
						var _bgr = real(_old[i])
						
						_old2[j] = color_get_red(_bgr) * COLOR_INVERSE
						_old2[j1] = color_get_green(_bgr) * COLOR_INVERSE
						_old2[j2] = color_get_blue(_bgr) * COLOR_INVERSE
						_bgr = real(_new[i])
						_new2[j] = color_get_red(_bgr) * COLOR_INVERSE
						_new2[j1] = color_get_green(_bgr) * COLOR_INVERSE
						_new2[j2] = color_get_blue(_bgr) * COLOR_INVERSE
						j += 3;
						++i
					}
					
					_pal[0] = _old2
					_pal[1] = _new2
				} else {
					print($"! ImageMap.load: Palette '{_palette}' not found")
					_palette = "default"
				}
			}
			
			ds_map_add(_image.variants, _palette, _pal)
			print($"ImageMap.load: Added palette '{_palette}' to '{_name}'")
			
			if not batch {
				post_batch()
			}
		}
		
		return _image
	}
	
	static get = function (_name, _palette = "default") {
		gml_pragma("forceinline")
		
		var _image = assets[? _name]
		
		if _image != undefined {
			var _variants = _image.variants
			
			return _variants[? _palette] ?? _variants[? "default"]
		}
		
		return undefined
	}
	
	static fetch = function (_name, _palette = "default") {
		gml_pragma("forceinline")
		
		load(_name, _palette)
		
		return get(_name, _palette)
	}
	
	static clear = function () {
		gml_pragma("forceinline")
		
		repeat ds_map_size(assets) {
			var _key = ds_map_find_first(assets)
			var _value = assets[? _key]
			
			if _value.transient {
				print($"! ImageMap.clear: Transient images are not supported ({_key})")
			}
			
			_value.destroy()
			ds_map_delete(assets, _key)
		}
		
		collage.Clear()
	}
}

global.images = new ImageMap()