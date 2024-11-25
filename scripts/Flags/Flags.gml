function Flags() constructor {
	flags = ds_map_create()
	
	static get = function (_key) {
		return flags[? _key]
	}
	
	static set = function (_key, _value) {
		flags[? _key] = _value
		
		return true
	}
	
	static increment = function (_key) {
		if not is_real(flags[? _key]) {
			flags[? _key] = 0
		}
		
		return ++flags[? _key]
	}
	
	static copy = function (_struct) {
		var _names = struct_get_names(_struct)
		var i = 0
		
		repeat struct_names_count(_struct) {
			var _name = _names[i++]
			
			set(_name, _struct[$ _name])
		}
	}
	
	static clear = function () {
		ds_map_clear(flags)
		
		return true
	}
	
	static write = function (_buffer) {
		var n = ds_map_size(flags)
		
		buffer_write(_buffer, buffer_u32, n)
		
		var _key = ds_map_find_first(flags)
		
		repeat n {
			buffer_write(_buffer, buffer_string, _key)
			buffer_write_dynamic(_buffer, flags[? _key])
			_key = ds_map_find_next(flags, _key)
		}
	}
	
	static read = function (_buffer) {
		clear()
		
		var n = buffer_read(_buffer, buffer_u32)
		
		repeat n {
			var _key = buffer_read(_buffer, buffer_string)
			var _value = buffer_read_dynamic(_buffer)
			
			flags[? _key] = _value
		}
	}
}

global.local_flags = new Flags()