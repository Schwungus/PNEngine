/// @desc Adds a new player to the session.
function net_add_player(_index, _ip, _port) {
	with global.netgame {
		if _index == undefined {
			_index = ds_list_find_index(players, undefined)
			
			if _index == -1 {
				if player_count >= INPUT_MAX_PLAYERS {
					return undefined
				}
				
				_index = player_count
			}
		}
		
		var _net = players[| _index]
		
		if _net != undefined {
			return _net
		}
		
		_net = new NetPlayer()
		
		var _player = global.players[_index]
		var _key = _ip + ":" + string(_port)
		
		with _net {
			session = other
			slot = _index
			player = _player
			ip = _ip
			port = _port
			key = _key
		}
		
		_player.net = _net
		player_activate(_player)
		players[| _index] = _net
		
		// Work around GameMaker quirk where in-between empty indices have a
		// value of 0
		_index = ds_list_find_index(players, 0)
		
		while _index != -1 {
			players[| _index] = undefined
			_index = ds_list_find_index(players, 0)
		}
		
		++player_count
		
		if master {
			clients[? _key] = _net
		}
		
		return _net
	}
	
	return undefined
}