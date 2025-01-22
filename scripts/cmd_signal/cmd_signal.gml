function cmd_signal(_args) {
	var _parse_args = string_split(_args, " ", true, 1)
	var n = array_length(_parse_args)
	
	if n == 0 {
		print("Usage: signal <name> [args]")
		
		exit
	}
	
	CMD_NO_DEMO
	
	var _name = _parse_args[0]
	var __args
	
	if n > 1 {
		try {
			__args = json_parse(_parse_args[1])
			
			if not is_array(__args) {
				print("! cmd_signal: \"args\" field has to be a JSON array")
				
				exit
			}
		} catch (e) {
			print($"! cmd_signal: Invalid \"args\" field ({e.longMessage})")
			
			exit
		}
	} else {
		__args = undefined
	}
	
	if not net_master() {
		var b = net_buffer_create(true, NetHeaders.CLIENT_SIGNAL, buffer_string, _name)
		var _argc = __args != undefined ? array_length(__args) : 0
		
		buffer_write(b, buffer_u8, _argc)
		
		var i = 0
		
		repeat _argc {
			buffer_write_dynamic(b, __args[i++])
		}
		
		global.netgame.send_host(b)
		
		exit
	}
	
	var _tick_buffer = inject_tick_packet()
	
	buffer_write(_tick_buffer, buffer_u8, TickPackets.SIGNAL)
	buffer_write(_tick_buffer, buffer_u8, 0) // Player slot (Always player 1 in local)
	buffer_write(_tick_buffer, buffer_string, _name)
	
	var _argc = __args != undefined ? array_length(__args) : 0
	
	buffer_write(_tick_buffer, buffer_u8, _argc)
	
	var i = 0
	
	repeat _argc {
		buffer_write_dynamic(_tick_buffer, __args[i++])
	}
}