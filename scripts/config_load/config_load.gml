function config_load() {
	config_reset()
	
	var _config = global.config
	var _json = json_load(CONFIG_PATH)
	
	if is_struct(_json) {
		var _cvars = variable_struct_get_names(_json)
		var i = 0
		
		repeat array_length(_cvars) {
			var _cvar = _cvars[i++]
			
			if variable_struct_exists(_config, _cvar) {
				config_set(_cvar, _json[$ _cvar])
			}
		}
	}
	
	try {
		_json = json_load(CONTROLS_PATH)
		input_player_import(_json)
	} catch (e) {
		print($"! config_load: Failed to import controls ({e})")
	}
}