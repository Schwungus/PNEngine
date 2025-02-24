function game_update_status() {
	var _status = ""
	var _game_status = global.game_status
	
	if _game_status & GameStatus.NETGAME {
		_status = "Online"
	}
	
	if _game_status & GameStatus.DEMO {
		if _status != "" {
			_status += ", "
		}
		
		_status = "Demo"
	}
	
	var _total = ds_list_size(global.players_ready) + ds_list_size(global.players_active)
	
	if _total > 1 {
		if _status != "" {
			_status += ", "
		}
		
		_status = $"{_total} players"
	}
	
	with global.level {
		np_setpresence(_status, rp_name, rp_icon, "")
	}
}