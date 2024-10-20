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
		var n = ds_map_size(queue)
		
		repeat n {
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
		
		repeat n {
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
					var _base = collage.GetImageInfo(_key + ":default")
					var _depth_disable = surface_get_depth_disable()
					var _blendenable = gpu_get_blendenable()
					
					surface_depth_disable(true)
					gpu_set_blendenable(false)
					
					var _sprite = undefined
					var _width = _base.GetWidth()
					var _height = _base.GetHeight()
					
					var _old = _pal[0]
					var _new = _pal[1]
					
					if _old[0] {
						global.palette_ext_shader.set()
					} else {
						global.palette_shader.set()
					}
					
					array_delete(_old, 0, 1)
					array_delete(_new, 0, 1)
					global.u_old.set(_old)
					global.u_new.set(_new)
					
					var i = 0
					
					repeat _frames {
						var _surface = surface_create(_width, _height)
						
						surface_set_target(_surface)
						draw_clear_alpha(c_black, 0)
						CollageDrawImageStretched(_base, i++, 0, 0, _width, _height)
						surface_reset_target()
						
						if _sprite == undefined {
							_sprite = sprite_create_from_surface(_surface, 0, 0, _width, _height, false, false, _x_offset, _y_offset)
						} else {
							sprite_add_from_surface(_sprite, _surface, 0, 0, _width, _height, false, false)
						}
						
						surface_free(_surface)
					}
					
					gpu_set_blendenable(_blendenable)
					shader_reset()
					surface_depth_disable(_depth_disable)
					
					collage.AddSprite(
						_sprite,
						_key + ":" + _vkey,
						true
					).SetPremultiplyAlpha(
						false
					).SetTiling(
						_image.x_repeat,
						_image.y_repeat
					).SetClump(
						true
					)
				}
				
				_vkey = ds_map_find_next(_variants, _vkey)
			}
			
			_key = ds_map_find_next(queue, _key)
		}
		
		collage.FinishBatch()
		collage.PrefetchPages()
		
		// 3. Prepare for dequeueing
		_key = ds_map_find_first(queue)
		
		repeat n {
			queue[? _key].name = _key
			_key = ds_map_find_next(queue, _key)
		}
		
		// 4. Dequeue to assets
		repeat n {
			_key = ds_map_find_first(queue)
			
			var _image = queue[? _key]
			var _variants = _image.variants
			var _vkey = ds_map_find_first(_variants)
			var _frames = _image.frames
			var _mipdefs = _image.mipmaps
			var _n_lods = _mipdefs == undefined ? 0 : array_length(_mipdefs)
			var _n_vecs = 4 + (_n_lods * 4)
			
			repeat ds_map_size(_variants) {
				var _ikey = _key + ":" + _vkey
				var _variant = collage.GetImageInfo(_ikey)
				var _mipmaps = []
				
				// Highest LOD (the texture itself)
				var i = 0
				
				repeat _frames {
					var _submips
					
					if array_length(_mipmaps) <= i {
						_submips = array_create(_n_vecs, 0)
						_mipmaps[i] = _submips
					} else {
						_submips = _mipmaps[i]
					}
					
					with _variant.GetUVs(i++) {
						_submips[0] = normLeft
						_submips[1] = normTop
						_submips[2] = normRight
						_submips[3] = normBottom
					}
				}
				
				// The rest
				i = 0
				
				repeat _n_lods {
					var _lod = collage.GetImageInfo(_mipdefs[i++].name + ":" + _vkey)
					var j = 0
					
					repeat _frames {
						var _submips = _mipmaps[j]
						var k = i * 4
						
						with _lod.GetUVs(j++) {
							_submips[k] = normLeft
							_submips[-~k] = normTop
							_submips[k + 2] = normRight
							_submips[k + 3] = normBottom
						}
					}
				}
				
				_variant.__mipmaps = _mipmaps
				_variant.__maxLOD = _n_lods
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
			
			if _mipmaps != undefined {
				var i = 0
				
				repeat array_length(_mipmaps) {
					var _mname = force_type(_mipmaps[i], "string")
					
					if _mname == _name {
						show_error("!!! ImageMap.load: YOU THOUGHT YOU COULD GET AWAY WITH THIS DIDN'T YOU", true)
					}
					
					var _mip = load(_mname, _palette)
					
					if _mip == undefined {
						show_error($"!!! ImageMap.load: Image '{_name}' has invalid LOD '{_mname}'", true)
					}
					
					_mipmaps[i++] = _mip
				}
			}
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
					var _ext = is_array(_old[0])
					var _n_vecs = (n * (_ext ? 4 : 3)) + 1
					var _old2 = array_create(_n_vecs, _ext)
					var _new2 = array_create(_n_vecs, _ext)
					var i = 0
					var j = 1
					
					if _ext {
						repeat n {
							var j1 = -~j
							var j2 = j + 2
							var j3 = j + 3
							var _vec2 = _old[i]
							var _bgr = real(_vec2[0])
							
							_old2[j] = color_get_red(_bgr) * COLOR_INVERSE
							_old2[j1] = color_get_green(_bgr) * COLOR_INVERSE
							_old2[j2] = color_get_blue(_bgr) * COLOR_INVERSE
							_old2[j3] = real(_vec2[1]) * COLOR_INVERSE
							_vec2 = _new[i]
							_bgr = real(_vec2[0])
							_new2[j] = color_get_red(_bgr) * COLOR_INVERSE
							_new2[j1] = color_get_green(_bgr) * COLOR_INVERSE
							_new2[j2] = color_get_blue(_bgr) * COLOR_INVERSE
							_new2[j3] = real(_vec2[1]) * COLOR_INVERSE
							j += 4;
							++i
						}
					} else {
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
			var _img = _variants[? _palette]
			
			if _img == undefined {
				print($"! ImageMap.get: Image '{_name}' variant '{_palette}' not found")
				
				return _variants[? "default"]
			}
			
			return _img
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