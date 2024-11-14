function cmd_config(_args) {
	var _parse_args = string_split(_args, " ", true, 1)
	var n = array_length(_parse_args)
	
	if n < 1 {
		print("Usage: config <name> [value]")
		
		exit
	}
	
	var _config = global.config
	var _key = _parse_args[0]
	
	if not struct_exists(_config, _key) {
		print($"! cmd_config: Unknown variable '{_key}'")
		
		exit
	}
	
	if n < 2 {
		print(_config[$ _key].value)
		
		exit
	}
	
	var _value
	
	try {
		_value = json_parse(_parse_args[1])
	} catch (e) {
		print($"! cmd_config: Failed to parse value ({e.longMessage})")
		
		exit
	}
	
	config_set(_key, _value)
}