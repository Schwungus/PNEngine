function Mod(_name) constructor {
	name = string_lower(_name) // Linux compatibility
	version = ""
	path = DATA_PATH + _name + "/"
	
	if not directory_exists(path) {
		show_error($"!!! Mod: '{_name}' not found", true)
	}
	
	static create_md5 = function (_path = path, _buffer = undefined) {
		var _temp_buffer = _buffer == undefined
		
		if _temp_buffer {
			_buffer = buffer_create(1, buffer_grow, 1)
		}
		
		var _files = []
		var _file = file_find_first(_path + "*.*", fa_directory)
		
		while _file != "" {
			array_push(_files, _path + _file)
			_file = file_find_next()
		}
		
		file_find_close()
		
		var i = 0
		
		repeat array_length(_files) {
			_file = _files[i++]
			
			if directory_exists(_file) {
				create_md5(_file + "/", _buffer)
				
				continue
			}
			
			var _file_buffer = buffer_load(_file)
			
			buffer_write(_buffer, buffer_text, buffer_md5(_file_buffer, 0, buffer_get_size(_file_buffer)))
			buffer_delete(_file_buffer)
		}
		
		var _md5 = buffer_md5(_buffer, 0, buffer_tell(_buffer))
		
		if _temp_buffer {
			buffer_delete(_buffer)
		}
		
		return _md5
	}
	
	md5 = create_md5()
	print($"Mod: Added '{_name}' ({md5})")
	ds_map_add(global.mods, name, self)
}