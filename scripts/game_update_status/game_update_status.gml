function game_update_status() {
	var _status = ""
	var _game_status = global.game_status
	
	if _game_status == GameStatus.NETGAME {
		_status = "Online"
		
		with global.netgame {
			if player_count > 1 {
				_status += $", {player_count} players"
			}
		}
	} else if _game_status & GameStatus.DEMO {
		_status = "Demo"
	} else {
		var _total = ds_list_size(global.players_ready) + ds_list_size(global.players_active)
		
		if _total > 1 {
			_status = $"{_total} players"
		}
	}
	
	with global.level {
		np_setpresence(_status, rp_name, rp_icon, "")
	}
}