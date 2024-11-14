function config_set(_key, _value, _update = true) {
	var _cvar = global.config[$ _key]
	
	if _cvar == undefined {
		print($"! config_set: Invalid cvar '{_key}'")
		
		return false
	}
	
	if _cvar.set(_value, _update) < 0 {
		print($"! config_set: Invalid value '{_value}' for cvar '{_key}'")
		
		return false
	}
	
	return true
}