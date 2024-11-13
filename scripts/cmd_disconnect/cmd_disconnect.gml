function cmd_disconnect(_args) {
	var _netgame = global.netgame
	
	if _netgame == undefined {
		print("! cmd_disconnect: Not in a netgame")
		
		return false
	}
	
	net_destroy()
	global.game_status = GameStatus.DEFAULT
	
	if global.input_mode == INPUT_SOURCE_MODE.JOIN {
		input_join_params_set(1, INPUT_MAX_PLAYERS, "leave", undefined, false)
		
		if not global.console {
			input_source_mode_set(INPUT_SOURCE_MODE.JOIN)
		}
	}
	
	player_activate(global.players[0], false)
	global.level.goto("lvlTitle")
	show_caption($"[c_red]Disconnected")
	
	return true
}