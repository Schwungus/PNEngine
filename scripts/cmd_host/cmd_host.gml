function cmd_host(_args) {
	CMD_NO_DEMO
	CMD_NO_DEMO_WRITE
	CMD_NO_NETGAME
	
	if global.level.name != "lvlTitle" {
		print("! cmd_host: Cannot host outside of lvlTitle")
		
		return false
	}
	
	if (global.players_ready + global.players_active) > 1 {
		print("! cmd_host: Cannot host with more than 1 local player")
		
		return false
	}
	
	if (global.players[0].status != PlayerStatus.ACTIVE) {
		print("! cmd_host: Cannot host while player 1 isn't active")
		
		return false
	}
	
	var _netgame = global.netgame
	
	if _netgame == undefined {
		_netgame = new Netgame()
		global.netgame = _netgame
	}
	
	var _parse_args = string_split(_args, " ", true)
	var _port = array_length(_parse_args) ? real(_parse_args[0]) : DEFAULT_PORT
	
	if not net_host(_port) {
		show_caption($"[c_red]No connection")
		net_destroy()
		
		return false
	}
	
	if global.input_mode == INPUT_SOURCE_MODE.JOIN {
		input_join_params_set(1, INPUT_MAX_PLAYERS, undefined, undefined, false)
		input_source_mode_set(INPUT_SOURCE_MODE.FIXED)
	}
	
	global.game_status = GameStatus.NETGAME
	show_caption($"[c_lime]Hosting on port {_port}")
	game_update_status()
	
	return true
}