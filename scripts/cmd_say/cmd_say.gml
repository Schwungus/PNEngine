function cmd_say(_args) {
	if _args == "" {
		print("Usage: say <message>")
		
		return false
	}
	
	var _netgame = global.netgame
	
	with _netgame {
		if not active {
			return false
		}
		
		var _message = string_trim(_args)
		
		if _message == "" {
			return false
		}
		
		if master {
			var _say = $"<{local_net.name}> {_message}"
			
			net_say(_say)
			global.ui_sounds.play(global.chat_sound)
			send_others(net_buffer_create(true, NetHeaders.PLAYER_SAID, buffer_u8, 0, buffer_string, _message))
		} else {
			send_host(net_buffer_create(true, NetHeaders.CLIENT_SAY, buffer_string, _message))
		}
		
		return true
	}
	
	return false
}