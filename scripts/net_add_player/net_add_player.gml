/// @desc Adds a new NetPlayer to the session and returns it for further handling.
function net_add_player(_index, _ip, _port) {
	with global.netgame {
		if _index == undefined {
			_index = ds_list_find_index(players, undefined)
			
			if _index == -1 {
				if player_count >= NET_MAX_PLAYERS {
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
		
		var _player = (_index > 0 and _index < INPUT_MAX_PLAYERS) ? global.players[_index] : undefined
		var _key = _ip + ":" + string(_port)
		
		with _net {
			session = other
			slot = _index
			ip = _ip
			port = _port
			key = _key
			
			if _player != undefined {
				_player.net = _net
				player = _player
				//player_activate(_player)
			}
		}
		
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