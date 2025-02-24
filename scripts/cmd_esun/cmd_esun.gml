function cmd_esun(_args) {
	if _args == "" {
		print("Usage: esun <vec5>")
		
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
		print("! cmd_esun: No active areas")
		
		exit
	}
	
	with _area {
		var _light = noone
		
		i = 0
		
		repeat MAX_LIGHTS {
			_light = lights[| i++]
			
			if _light != noone {
				break
			}
		}
		
		if _light == noone {
			print("! cmd_esun: No lights in area")
			
			exit
		}
		
		with _light {
			// Parse color
			try {
				var _vec5 = color_to_vec5(json_parse(_args))
				
				color = _vec5[4]
				alpha = _vec5[3]
				
				if handle != -1 {
					offset = handle * LightData.__SIZE
					light_data[offset + LightData.RED] = _vec5[0]
					light_data[offset + LightData.GREEN] = _vec5[1]
					light_data[offset + LightData.BLUE] = _vec5[2]
					light_data[offset + LightData.ALPHA] = alpha
				}
			} catch (e) {
				print($"! cmd_esun: Failed to parse color ({e})")
			}
		}
	}
}