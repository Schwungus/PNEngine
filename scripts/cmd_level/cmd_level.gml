function cmd_level(_args) {
	var _parse_args = string_split(_args, " ", true)
	var n = array_length(_parse_args)
	
	if n == 0 {
		print("Usage: level <name> [area] [tag]")
		
		exit
	}
	
	CMD_NO_CLIENT
	
	var _level = _parse_args[0]
	
	if mod_find_file("levels/" + _level + ".*") == "" {
		print($"! cmd_level: '{_level}' not found")
		
		exit
	}
	
	if not global.title_loaded {
		var _netgame = global.netgame
		
		if _netgame != undefined {
			with _netgame {
				if active and master {
					var b = net_buffer_create(true, NetHeaders.HOST_STATES_FLAGS, buffer_u8, INPUT_MAX_PLAYERS)
					
					// States
					var _players = global.players
					var i = 0
					
					repeat INPUT_MAX_PLAYERS {
						buffer_write(b, buffer_u8, i)
						_players[i++].write_states(b)
					}
					
					// Flags
					global.global_flags.write(b)
					send_others(b)
				}
			}
		}
		
		global.title_loaded = true
	}
	
	var _area = n >= 2 ? real(_parse_args[1]) : 0
	var _tag = n >= 3 ? real(_parse_args[2]) : ThingTags.NONE
	var _tick_buffer = inject_tick_packet()
	
	buffer_write(_tick_buffer, buffer_u8, TickPackets.LEVEL)
	buffer_write(_tick_buffer, buffer_string, _level)
	buffer_write(_tick_buffer, buffer_u32, _area)
	buffer_write(_tick_buffer, buffer_s32, _tag)
}