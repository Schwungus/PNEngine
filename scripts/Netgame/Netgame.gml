#macro WRITE_RELIABLE buffer_poke(_buffer, 0, buffer_u32, reliable_write_index)\
\
var b = buffer_create(_size, buffer_fixed, 1)\
\
buffer_copy(_buffer, 0, _size, b, 0)\
ds_map_add(reliable_write, reliable_write_index++, b)\
time_source_start(reliable_time_source)

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
	local_net = undefined
	local_player = undefined
	
	delay = 0
	timestamp = current_time
	tick_queue = ds_queue_create()
	tick_count = 0
	ack_count = 0
	stall_time = 0
	
	chat = false
	chat_log = ds_list_create()
	chat_fade = array_create(MAX_LINES, 0)
	chat_previous = ""
	
	code = "NET_UNKNOWN"
	connect_success_callback = undefined
	connect_fail_callback = undefined
	was_connected_before = false
	
#region Sending Packets
	/// @desc Sends a packet directly to the specified IP address and port. (HOST AND CLIENT)
	static send_direct = function (_ip, _port, _buffer, _size = undefined, _dispose = true, _overwrite = true) {
		_size ??= buffer_get_size(_buffer)
		
		if _overwrite and buffer_peek(_buffer, 0, buffer_u32) {
			var _player = clients[? $"{_ip}:{_port}"]
			
			if _player != undefined {
				with _player {
					WRITE_RELIABLE
				}
			}
		}
		
		network_send_udp_raw(socket, _ip, _port, _buffer, _size)
		
		if _dispose {
			buffer_delete(_buffer)
		}
	}
	
	/// @desc Sends a packet to a NetPlayer mapped to a client key. (HOST ONLY)
	static send_client = function (_key, _buffer, _size = undefined, _dispose = true, _overwrite = true) {
		_size ??= buffer_get_size(_buffer)
		
		if _overwrite and buffer_peek(_buffer, 0, buffer_u32) {
			var _player = clients[? _key]
			
			if _player != undefined {
				with _player {
					WRITE_RELIABLE
				}
				
				network_send_udp_raw(socket, _player.ip, _player.port, _buffer, _size)
			}
		}
		
		if _dispose {
			buffer_delete(_buffer)
		}
	}
	
	/// @desc Sends a packet directly to a NetPlayer. (HOST ONLY)
	static send_player = function (_player, _buffer, _size = undefined, _dispose = true, _overwrite = true) {
		_size ??= buffer_get_size(_buffer)
		
		if _overwrite and buffer_peek(_buffer, 0, buffer_u32) {
			with _player {
				WRITE_RELIABLE
			}
		}
		
		network_send_udp_raw(socket, _player.ip, _player.port, _buffer, _size)
		
		if _dispose {
			buffer_delete(_buffer)
		}
	}
	
	/// @desc Sends a packet to the host. (HOST AND CLIENT)
	static send_host = function (_buffer, _size = undefined, _dispose = true, _overwrite = true) {
		_size ??= buffer_get_size(_buffer)
		
		if _overwrite and buffer_peek(_buffer, 0, buffer_u32) {
			with players[| 0] {
				WRITE_RELIABLE
			}
		}
		
		network_send_udp_raw(socket, ip, port, _buffer, _size)
		
		if _dispose {
			buffer_delete(_buffer)
		}
	}
	
	/// @desc Sends a packet to other clients. (HOST ONLY)
	static send_others = function (_buffer, _size = undefined, _dispose = true, _overwrite = true) {
		_size ??= buffer_get_size(_buffer)
		
		var i = 0
		
		repeat ds_list_size(players) {
			var _player = players[| i++]
			
			if _player != undefined and _player != local_net {
				send_player(_player, _buffer, _size, false, _overwrite)
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
					net_player_destroy(_player)
					send_others(net_buffer_create(true, NetHeaders.PLAYER_LEFT, buffer_u8, _player.slot))
					
					continue
				}
				
				++_player.ping
			}
			
			send_others(net_buffer_create(false, NetHeaders.HOST_PING))
		}
	}, [], -1)
	
	static connect_time_source = time_source_create(time_source_global, 10, time_source_units_seconds, function () {
		with global.netgame {
			if connect_fail_callback != undefined {
				connect_fail_callback()
			}
			
			net_destroy()
		}
	}, [], 1)
	
	static timeout_time_source = time_source_create(time_source_global, 30, time_source_units_seconds, function () {
		with global.netgame {
			code = "NET_TIMEOUT"
			net_disconnect()
			was_connected_before = true
			
			if connect_fail_callback != undefined {
				connect_fail_callback()
			}
			
			was_connected_before = false
			net_destroy()
		}
	}, [], 1)
#endregion
}