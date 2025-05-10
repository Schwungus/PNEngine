function Image() : Asset() constructor {
	original = undefined
	variants = ds_map_create()
	frames = 1
	x_offset = 0
	y_offset = 0
	x_repeat = true
	y_repeat = true
	mipmaps = undefined
	
	/// @param {String} palette
	/// @return {Struct.__CollageImageClass|Undefined}
	static get_variant = function (_palette) {
		gml_pragma("forceinline")
		
		return variants[? _palette]
	}
	
	static destroy = function () {
		gml_pragma("forceinline")
		
		ds_map_destroy(variants)
	}
}