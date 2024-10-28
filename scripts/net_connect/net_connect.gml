/// @desc Connects to a session on the specified IP and port and returns true when connecting.
function net_connect(_ip = "127.0.0.1", _port = DEFAULT_PORT, _success_callback = undefined, _fail_callback = undefined) {
	with global.netgame {
		net_disconnect()
		ip = network_resolve(_ip)
		port = _port
		socket = network_create_socket(network_socket_udp)
		
		if socket < 0 {
			return false
		}
		
		master = false
		active = false
		send_direct(_ip, _port, net_buffer_create(false, NetHeaders.CLIENT_CONNECT))
		code = "NET_TIMEOUT"
		connect_success_callback = _success_callback
		connect_fail_callback = _fail_callback
		time_source_start(connect_time_source)
		
		return true
	}
	
	return false
}