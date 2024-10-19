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
		
		// 3. Dequeue to assets
		repeat ds_map_size(queue) {
			_key = ds_map_find_first(queue)
			
			var _image = queue[? _key]
			
			_image.name = _key
			
			var _variants = _image.variants
			var _vkey = ds_map_find_first(_variants)
			
			repeat ds_map_size(_variants) {
				_variants[? _vkey] = CollageImageGetInfo(_key + ":" + _vkey)
				_vkey = ds_map_find_next(_variants, _vkey)
			}
			
			var _base = CollageImageGetInfo(_key + ":default")
			var _mipmaps = []
			var j = 0
			
			repeat _image.frames {
				var _submips
				
				if array_length(_mipmaps) <= j {
					_submips = array_create(4, 0)
					_mipmaps[j] = _submips
				} else {
					_submips = _mipmaps[j]
				}
				
				with _base.GetUVs(j) {
					_submips[0] = normLeft
					_submips[1] = normTop
					_submips[2] = normRight
					_submips[3] = normBottom
				}
				
				++j
			}
			
			_base.__mipmaps = _mipmaps
			_base.__maxLOD = 0
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
		
		var _pal = undefined
		
		if _palette != "default" {
			var _pal_file = mod_find_file("palettes/" + _palette + ".json")
			
			if _pal_file != "" {
				// Always load default palette first so we can get the
				// original image.
				load(_name)
				_pal = json_load(_pal_file)
			} else {
				print($"! ImageMap.load: Palette '{_palette}' not found")
				_palette = "default"
			}
		}
		
		if ds_map_add(_image.variants, _palette, _pal) {
			print($"ImageMap.load: Added palette '{_palette}' to '{_name}'")
		}
		
		if not batch {
			post_batch()
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