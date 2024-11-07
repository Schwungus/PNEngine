function cmd_dend(_args) {
	if not global.demo_write {
		if global.demo_buffer == undefined {
			print("! cmd_dend: Not recording")
		} else {
			print("! cmd_dend: Stopping")
			buffer_delete(global.demo_buffer)
			global.demo_buffer = undefined
			global.demo_client = false
			global.game_status = GameStatus.DEFAULT
			
			var _devices = input_players_get_status().__players
			var _players = global.players
			
			i = 0
			
			repeat INPUT_MAX_PLAYERS {
				var _player = _players[i]
				var _status = _devices[i]
				
				if _status == INPUT_STATUS.NEWLY_CONNECTED or _status == INPUT_STATUS.CONNECTED {
					player_activate(_player)
				} else {
					player_deactivate(_player)
				}
				
				++i
			}
			
			global.level.goto("lvlTitle")
		}
		
		exit
	}
	
	var _demo_buffer = global.demo_buffer
	
	if _demo_buffer == undefined {
		global.demo_write = false
		global.demo_client = false
		print("cmd_dend: Cancelling")
		
		exit
	}
	
	var _parse_args = string_split(_args, " ", true)
	var n = array_length(_parse_args)
	
	if n == 0 {
		print("Usage: dend <filename>")
		
		exit
	}
	
	buffer_write(_demo_buffer, buffer_u32, 0xFFFFFFFF)
	buffer_resize(_demo_buffer, buffer_tell(_demo_buffer))
	
	var _filename = _parse_args[0] + ".pnd"
	
	buffer_save(_demo_buffer, DEMOS_PATH + _filename)
	buffer_delete(_demo_buffer)
	global.demo_write = false
	global.demo_buffer = undefined
	global.demo_client = false
	print($"cmd_dend: Saved as '{_filename}'")
}