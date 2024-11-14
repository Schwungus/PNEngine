function cmd_connect(_args) {
	var _parse_args = string_split(_args, " ", true)
	var n = array_length(_parse_args)
	
	if n == 0 {
		print("Usage: connect <ip> [port]")
		
		return false
	}
	
	CMD_NO_DEMO
	CMD_NO_NETGAME
	
	if global.level.name != "lvlTitle" {
		print("! cmd_connect: Cannot connect outside of lvlTitle")
		
		return false
	}
	
	if (ds_list_size(global.players_ready) + ds_list_size(global.players_active)) > 1 {
		print("! cmd_connect: Cannot connect with more than 1 local player")
		
		return false
	}
	
	var _netgame = global.netgame
	
	if _netgame == undefined {
		_netgame = new Netgame()
		global.netgame = _netgame
	}
	
	var _ip = _parse_args[0]
	var _port = n >= 2 ? real(_parse_args[1]) : DEFAULT_PORT
	
	if not net_connect(_ip, _port, function () {
		fmod_channel_control_set_paused(global.world_channel_group, false)
		
		with TitleBase {
			f_frozen = true
		}
		
		global.game_status = GameStatus.NETGAME
		proControl.load_state = LoadStates.NONE
		net_say($"Connected", C_AB_GREEN)
		net_say($"Press <{string_input("chat")}> to chat", C_AB_GREEN)
	}, function () {
		if global.input_mode == INPUT_SOURCE_MODE.JOIN {
			input_join_params_set(1, INPUT_MAX_PLAYERS, "leave", undefined, false)
			
			if not global.console {
				input_source_mode_set(INPUT_SOURCE_MODE.JOIN)
			}
		}
		
		var _netgame = global.netgame
		
		if _netgame.was_connected_before {
			global.level.goto("lvlTitle")
		} else {
			proControl.load_state = LoadStates.NONE
		}
		
		global.game_status = GameStatus.DEFAULT
		show_caption($"[c_red]Lost connection ({_netgame.code})")
		net_destroy()
	}) {
		show_caption($"[c_red]No connection")
		
		return false
	}
	
	input_join_params_set(1, INPUT_MAX_PLAYERS, undefined, undefined, false)
	input_source_mode_set(INPUT_SOURCE_MODE.FIXED)
	proControl.load_state = LoadStates.CONNECT
	show_caption($"Connecting to {_ip}:{_port}...", infinity)
	
	return true
}