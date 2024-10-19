function Netgame() constructor {
	active = false
	
	socket = undefined
	ip = "127.0.0.1"
	port = DEFAULT_PORT
	
	master = true
	players = ds_list_create()
	clients = ds_map_create()
	player_count = 0
	local_slot = 0
	
	tick_queue = ds_queue_create()
	tick_count = 0
	ack_count = 0
	stall_time = 0
	load_level = undefined
	load_area = undefined
	load_tag = undefined
	load_queue = false
	
	code = "NET_UNKNOWN"
	connect_success_callback = undefined
	connect_fail_callback = undefined
	was_connected_before = false
	
	/// @desc Hosts a session on the specified port and returns true when listening.
	static host = function (_port = DEFAULT_PORT) {
		disconnect()
		ip = "127.0.0.1"
		port = _port
		socket = network_create_socket_ext(network_socket_udp, _port)
		
		if socket < 0 {
			return false
		}
		
		master = true
		active = true
		local_slot = 0
		ack_count = 1
		
		with add_player(0, "127.0.0.1", _port) {
			name = global.config.name
			local = true
			tick_acked = true
		}
		
		time_source_start(ping_time_source)
		
		return true
	}
	
	/// @desc Connects to a session on the specified IP and port and returns true when connecting.
	static connect = function (_ip = "127.0.0.1", _port = DEFAULT_PORT, _success_callback = undefined, _fail_callback = undefined) {
		disconnect()
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
	
	/// @desc Adds a new player to the session.
	static add_player = function (_index, _ip, _port) {
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
		_player.activate()
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
	
	/// @desc Disconnects from the current session and returns true if successful.
	static disconnect = function () {
		time_source_stop(ports_time_source)
		time_source_stop(ping_time_source)
		time_source_stop(connect_time_source)
		time_source_stop(timeout_time_source)
		
		if ds_exists(tick_queue, ds_type_queue) {
			ds_queue_clear(tick_queue)
		}
		
		if not active {
			if socket != undefined {
				network_destroy(socket)
				socket = undefined
			}
			
			return false
		}
		
		if master {
			send(SEND_OTHERS, net_buffer_create(false, NetHeaders.HOST_DISCONNECT))
		} else {
			send(SEND_HOST, net_buffer_create(false, NetHeaders.CLIENT_DISCONNECT))
		}
		
		var i = ds_list_size(players)
		
		while i {
			var _player = players[| --i]
			
			if _player != undefined {
				_player.destroy()
			}
		}
		
		network_destroy(socket)
		socket = undefined
		active = false
		
		return true
	}
	
	/// @desc Destroys the struct, disconnecting from the current session in the process.
	static destroy = function () {
		disconnect()
		ds_list_destroy(players)
		ds_map_destroy(clients)
		
		if ds_exists(tick_queue, ds_type_queue) {
			ds_queue_destroy(tick_queue)
		}
		
		if global.netgame == self {
			global.netgame = undefined
		}
	}
	
#region Sending Packets
	/// @desc Sends a packet directly to the specified IP address and port.
	static send_direct = function (_ip, _port, _buffer, _size = undefined, _dispose = true) {
		_size ??= buffer_get_size(_buffer)
		network_send_udp_raw(socket, _ip, _port, _buffer, _size)
		
		if _dispose {
			buffer_delete(_buffer)
		}
	}
	
	/// @desc Sends a packet to a specific player or group.
	static send = function (_to, _buffer, _size = undefined, _dispose = true, _overwrite = true) {
		if not active {
			exit
		}
		
		_size ??= buffer_get_size(_buffer)
		
		switch _to {
			case SEND_HOST: send(0, _buffer, _size, false, _overwrite) break
			
			case SEND_ALL: {
				var i = 0
				
				repeat ds_list_size(players) {
					if players[| i] != undefined {
						send(i, _buffer, _size, false, _overwrite)
					}
					
					++i
				}
				
				break
			}
			
			case SEND_OTHERS: {
				var i = 0
				
				repeat ds_list_size(players) {
					var _player = players[| i]
					
					if _player != undefined and not _player.local {
						send(i, _buffer, _size, false, _overwrite)
					}
					
					++i
				}
				
				break
			}
			
			default: {
				var _player = players[| _to]
				
				if _player == undefined {
					break
				}
				
				var _ip = _player.ip
				var _port = _player.port
				
				if _port <= 0 and not master {
					_ip = ip
					_port = port
				}
				
				if _overwrite {
					var _pos = buffer_tell(_buffer)
					
					buffer_seek(_buffer, buffer_seek_start, 0)
					
					var _reliable = buffer_read(_buffer, buffer_u32)
					
					buffer_write(_buffer, buffer_u8, local_slot)
					buffer_write(_buffer, buffer_u8, _to)
					buffer_seek(_buffer, buffer_seek_start, _pos)
					
					if _reliable {
						with _player {
							++reliable_index
							buffer_poke(_buffer, 0, buffer_u32, reliable_index)
							
							var b = buffer_create(_size, buffer_fixed, 1)
							
							buffer_copy(_buffer, 0, _size, b, 0)
							ds_list_add(reliable, b)
							time_source_start(reliable_time_source)
						}
					}
				}
				
				network_send_udp_raw(socket, _ip, _port, _buffer, _size)
				
				break
			}
		}
		
		if _dispose {
			buffer_delete(_buffer)
		}
	}
#endregion
	
#region Time Sources
	static ports_time_source = time_source_create(time_source_global, 30, time_source_units_seconds, function () {
		with global.netgame {
			var _key = ds_map_find_last(clients)
			
			while true {
				if _key == undefined {
					break
				}
				
				var _client = clients[? _key]
				
				if _client == undefined {
					ds_map_delete(clients, _key)
					_key = ds_map_find_last(clients)
					
					continue
				}
				
				_key = ds_map_find_previous(clients, _key)
			}
		}
	}, [], 1)
	
	static ping_time_source = time_source_create(time_source_global, 1, time_source_units_seconds, function () {
		with global.netgame {
			var i = ds_list_size(players)
			
			while i {
				var _player = players[| --i]
				
				if _player == undefined or _player.local {
					continue
				}
				
				// Kick the client if they're inactive for over 30 seconds
				if _player.ping >= 30 {
					print($"! Netgame.ping_time_source: Player {-~i} timed out")
					_player.destroy()
					send(SEND_OTHERS, net_buffer_create(true, NetHeaders.PLAYER_LEFT, buffer_u8, _player.slot))
					
					continue
				}
				
				++_player.ping
			}
			
			send(SEND_OTHERS, net_buffer_create(false, NetHeaders.HOST_PING))
		}
	}, [], -1)
	
	static connect_time_source = time_source_create(time_source_global, 10, time_source_units_seconds, function () {
		with global.netgame {
			if connect_fail_callback != undefined {
				connect_fail_callback()
			}
			
			destroy()
		}
	}, [], 1)
	
	static timeout_time_source = time_source_create(time_source_global, 30, time_source_units_seconds, function () {
		with global.netgame {
			code = "NET_TIMEOUT"
			disconnect()
			was_connected_before = true
			
			if connect_fail_callback != undefined {
				connect_fail_callback()
			}
			
			was_connected_before = false
			destroy()
		}
	}, [], 1)
#endregion
}