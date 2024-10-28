function cmd_dend(_args) {
	if not global.demo_write {
		if global.demo_buffer == undefined {
			print("! cmd_dend: Not recording")
		} else {
			print("! cmd_dend: Stopping")
			buffer_delete(global.demo_buffer)
			global.demo_buffer = undefined
			global.demo_time = 0
			global.demo_next = 0
			
			var _demo_input = global.demo_input
			var i = 0
			
			repeat INPUT_MAX_PLAYERS {
				var _input = _demo_input[i++]
				var j = 0
				
				repeat PlayerInputs.__SIZE {
					_input[j++] = 0
				}
			}
			
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
		print("cmd_dend: Cancelling")
		
		exit
	}
	
	var _parse_args = string_split(_args, " ", true)
	var n = array_length(_parse_args)
	
	if n == 0 {
		print("Usage: dend <filename>")
		
		exit
	}
	
	buffer_write(_demo_buffer, buffer_u32, global.demo_time)
	buffer_write(_demo_buffer, buffer_u8, DemoPackets.END)
	
	var _filename = _parse_args[0] + ".pnd"
	
	buffer_save(_demo_buffer, DEMOS_PATH + _filename)
	buffer_delete(_demo_buffer)
	global.demo_write = false
	global.demo_buffer = undefined
	global.demo_time = 0
	global.demo_next = 0
	
	var _demo_input = global.demo_input
	var i = 0
	
	repeat INPUT_MAX_PLAYERS {
		var _input = _demo_input[i++]
		var j = 0
		
		repeat PlayerInputs.__SIZE {
			_input[j++] = 0
		}
	}
	
	print($"cmd_dend: Saved as '{_filename}'")
}