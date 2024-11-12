function config_set(_key, _value) {
	var _config = global.config
	
	if not struct_exists(_config, _key) {
		print($"! config_set: Invalid cvar '{_key}'")
		
		return false
	}
	
	var _trigger = global.config_trigger[$ _key]
	
	if _trigger != undefined and not _trigger(_value) {
		print($"! config_set: Invalid value '{_value}' for cvar '{_key}'")
		
		return false
	}
	
	_config[$ _key] = _value
	
	if global.config_refresh[$ _value] {
		config_update()
	}
	
	return true
}