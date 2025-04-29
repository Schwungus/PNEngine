function config_load() {
	struct_foreach(global.config, function (_name, _value) {
		with _value {
			set(default_value, false)
		}
	})
	
	var _json = json_load(CONFIG_PATH)
	
	if is_struct(_json) {
		var _cvars = variable_struct_get_names(_json)
		var i = 0
		
		repeat array_length(_cvars) {
			var _cvar = _cvars[i++]
			
			config_set(_cvar, _json[$ _cvar], false)
		}
	}
	
	config_update()
	
	try {
		_json = json_load(KEYBOARD_PATH)
		InputBindingsImport(false, _json)
	} catch (e) {
		print($"! config_load: Failed to import keyboard+mouse controls ({e})")
	}
	
	try {
		_json = json_load(GAMEPAD_PATH)
		InputBindingsImport(true, _json)
	} catch (e) {
		print($"! config_load: Failed to import keyboard+mouse controls ({e})")
	}
}