function cmd_efogr(_args) {
	if _args == "" {
		print("Usage: efogr <vec2>")
		
		exit
	}
	
	var _area = undefined
	
	// Get first active area
	var _players = global.players
	var i = 0
	
	repeat INPUT_MAX_PLAYERS {
		var _player = _players[i++]
		
		if _player.status != PlayerStatus.ACTIVE {
			continue
		}
		
		_area = _player.area
		
		if _area == undefined {
			continue
		}
		
		break
	}
	
	if _area == undefined {
		print("! cmd_efogr: No active areas")
		
		exit
	}
	
	// Parse color
	try {
		var _vec2 = force_type(json_parse(_args), "array")
		
		if array_length(_vec2) != 2 {
			throw "Array must have 2 elements"
		}
		
		_area.fog_distance = _vec2
	} catch (e) {
		print($"! cmd_efogr: Failed to parse vec2 ({e})")
	}
}