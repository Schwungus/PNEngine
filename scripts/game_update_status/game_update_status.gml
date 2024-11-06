function game_update_status() {
	var _status = ""
	var _total = ds_list_size(global.players_ready) + ds_list_size(global.players_active)
	var _game_status = global.game_status
	
	if _game_status == GameStatus.NETGAME {
		_status = _total > 1 ? $"Online, {_total} players" : "Online"
	} else if _game_status & GameStatus.DEMO {
		_status = "Demo"
	} else if _total > 1 {
		_status = $"{_total} players"
	}
	
	with global.level {
		np_setpresence(_status, rp_name, rp_icon, "")
	}
}