function cmd_eamb(_args) {
	if _args == "" {
		print("Usage: eamb <vec5>")
		
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
		print("! cmd_eamb: No active areas")
		
		exit
	}
	
	// Parse color
	try {
		_area.ambient_color = color_to_vec5(json_parse(_args))
	} catch (e) {
		print($"! cmd_eamb: Failed to parse color ({e})")
	}
}