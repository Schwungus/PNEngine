/// @desc Hosts a session on the specified port and returns true when listening.
function net_host(_port = DEFAULT_PORT) {
	with global.netgame {
		net_disconnect()
		ip = "127.0.0.1"
		port = _port
		socket = network_create_socket_ext(network_socket_udp, _port)
		
		if socket < 0 {
			return false
		}
		
		master = true
		active = true
		local_slot = 0
		
		with net_add_player(0, "127.0.0.1", _port) {
			name = global.config.name.value
			local = true
			other.local_net = self
			other.local_player = player
			player_activate(player, false)
		}
		
		time_source_start(ping_time_source)
		
		return true
	}
	
	return false
}