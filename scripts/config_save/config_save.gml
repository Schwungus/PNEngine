function config_save() {
	var _config = global.config
	var _json = {}
	var _keys = struct_get_names(_config)
	var i = 0
	
	repeat array_length(_keys) {
		var _key = _keys[i++]
		
		_json[$ _key] = _config[$ _key].value
	}
	
	var _buffer = buffer_create(1, buffer_grow, 1)
	
	buffer_write(_buffer, buffer_text, json_stringify(_json, true))
	buffer_save(_buffer, CONFIG_PATH)
	buffer_resize(_buffer, 1)
	buffer_seek(_buffer, buffer_seek_start, 0)
	buffer_write(_buffer, buffer_text, InputBindingsExport(false))
	buffer_save(_buffer, KEYBOARD_PATH)
	buffer_resize(_buffer, 1)
	buffer_seek(_buffer, buffer_seek_start, 0)
	buffer_write(_buffer, buffer_text, InputBindingsExport(true))
	buffer_save(_buffer, GAMEPAD_PATH)
	buffer_delete(_buffer)
}