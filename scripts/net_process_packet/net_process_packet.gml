#macro PACKET_FOR_HOST if not master {break}
#macro PACKET_FOR_CLIENT if master {break}

function net_process_packet(_netgame, _ip, _port, _buffer, _reliable, _header) {
	with _netgame {
		switch _header {
			case NetHeaders.ACK: {
				var _net = master ? clients[? $"{_ip}:{_port}"] : players[| 0]
				
				if _net == undefined {
					break
				}
				
				var _index = buffer_read(_buffer, buffer_u32)
				
				with _net {
					var b = reliable_write[? _index]
					
					if b == undefined {
						break
					}
					
					buffer_delete(b)
					ds_map_delete(reliable_write, _index)
				}
				
				break
			}
			
			case NetHeaders.CLIENT_CONNECT: {
				PACKET_FOR_HOST
				
				var _key = $"{_ip}:{_port}"
				
				// Ignore connect requests from already existing clients.
				if ds_map_exists(clients, _key) {
					break
				}
				
				// Is the server full?
				if player_count >= INPUT_MAX_PLAYERS {
					send_direct(_ip, _port, net_buffer_create(false, NetHeaders.HOST_BLOCK_CLIENT, buffer_string, "NET_FULL"))
					
					break
				}
				
				// Is the game not active?
				if global.level.name != "lvlTitle" {
					send_direct(_ip, _port, net_buffer_create(false, NetHeaders.HOST_BLOCK_CLIENT, buffer_string, "NET_ACTIVE"))
					
					break
				}
				
				// Request more information from client.
				send_direct(_ip, _port, net_buffer_create(false, NetHeaders.HOST_CHECK_CLIENT))
				ds_map_add(clients, _key, undefined)
				time_source_start(ports_time_source)
				print($"net_process_packet: Got valid connect request from client {_key}")
				
				break
			}
			
			case NetHeaders.CLIENT_VERIFY: {
				PACKET_FOR_HOST
				
				var _key = $"{_ip}:{_port}"
				
				// Ignore verification from already existing clients.
				if ds_map_exists(clients, _key) and clients[? _key] != undefined {
					break
				}
				
				// Do PNEngine versions match?
				var _version = buffer_read(_buffer, buffer_string)
				
				if _version != GM_version {
					print($"! net_process_packet: Client {_key} version doesn't match ({_version} =/= {GM_version}), blocking")
					send_direct(_ip, _port, net_buffer_create(false, NetHeaders.HOST_BLOCK_CLIENT, buffer_string, "NET_VERSION"))
					
					break
				}
				
				// Do all active mods match?
				var _md15 = buffer_read(_buffer, buffer_string)
				var _target_md15 = cmd_md15("", false)
				
				if _md15 != _target_md15 {
					print($"! net_process_packet: Client {_key} game hash doesn't match ({_md15} =/= {_target_md15}), blocking")
					send_direct(_ip, _port, net_buffer_create(false, NetHeaders.HOST_BLOCK_CLIENT, buffer_string, "NET_MODS"))
					
					break
				}
				
				send_direct(_ip, _port, net_buffer_create(false, NetHeaders.HOST_ALLOW_CLIENT))
				print($"net_process_packet: Verified client {_key}")
				
				break
			}
			
			case NetHeaders.CLIENT_SEND_INFO: {
				PACKET_FOR_HOST
				
				var _key = $"{_ip}:{_port}"
				
				// Ignore information from already existing clients.
				if ds_map_exists(clients, _key) and clients[? _key] != undefined {
					break
				}
				
				// Block the unfortunate new client if another one managed to
				// join before them.
				if player_count >= INPUT_MAX_PLAYERS {
					send_direct(_ip, _port, net_buffer_create(false, NetHeaders.HOST_BLOCK_CLIENT, buffer_string, "NET_FULL"))
					
					break
				}
				
				// Block the unfortunate new client if we already managed to
				// get out of the title screen.
				if global.level.name != "lvlTitle" {
					send_direct(_ip, _port, net_buffer_create(false, NetHeaders.HOST_BLOCK_CLIENT, buffer_string, "NET_ACTIVE"))
					
					break
				}
				
				// Send other clients' info to new client.
				var _new_player = net_add_player(undefined, _ip, _port)
				var b = net_buffer_create(false, NetHeaders.HOST_ADD_CLIENT, buffer_u8, _new_player.slot, buffer_u8, player_count - 1)
				var j = 0
				
				repeat player_count {
					var _player = players[| j]
					
					if not (_player == undefined or _player == _new_player) {
						with _player {
							print($"net_process_packet: Sending info from Player {-~j} ({name})")
							buffer_write(b, buffer_u8, j)
							buffer_write(b, buffer_u8, player == undefined ? PlayerStatus.INACTIVE : player.status)
							buffer_write(b, buffer_string, name)
						}
					}
					
					++j
				}
				
				send_player(_new_player, b)
				
				// Send new client info to everyone
				var _slot = _new_player.slot
				var _name = buffer_read(_buffer, buffer_string)
				
				_new_player.name = _name
				player_activate(_new_player.player, false)
				send_others(net_buffer_create(true, NetHeaders.PLAYER_JOINED, buffer_u8, _slot, buffer_string, _name))
				net_say($"{_name} joined", c_yellow)
				game_update_status()
				
				break
			}
			
			case NetHeaders.CLIENT_DISCONNECT: {
				PACKET_FOR_HOST
				
				var _key = $"{_ip}:{_port}"
				
				// Ignore ghost clients.
				if not ds_map_exists(clients, _key) {
					break
				}
				
				var _other = clients[? _key]
				
				if _other == undefined {
					ds_map_delete(clients, _key)
					
					break
				}
				
				var b = net_buffer_create(true, NetHeaders.PLAYER_LEFT)
				
				with _other {
					buffer_write(b, buffer_u8, slot)
					net_say($"{name} left", c_yellow)
				}
				
				send_others(b)
				
				var _player = net_player_destroy(_other)
				var _tick_buffer = inject_tick_packet()
				
				buffer_write(_tick_buffer, buffer_u8, TickPackets.DEACTIVATE)
				buffer_write(_tick_buffer, buffer_u8, _player.slot)
				game_update_status()
				
				break
			}
			
			case NetHeaders.CLIENT_PONG: {
				PACKET_FOR_HOST
				
				var _client = clients[? $"{_ip}:{_port}"]
				
				if _client != undefined {
					_client.ping = 0
				}
				
				break
			}
			
			case NetHeaders.HOST_CHECK_CLIENT: {
				PACKET_FOR_CLIENT
				
				send_direct(_ip, _port, net_buffer_create(false, NetHeaders.CLIENT_VERIFY,
					buffer_string, GM_version,
					buffer_string, cmd_md15("", false)
				))
				
				print("net_process_packet: Found connection from server")
				
				break
			}
			
			case NetHeaders.HOST_BLOCK_CLIENT: {
				PACKET_FOR_CLIENT
				net_disconnect()
				code = buffer_read(_buffer, buffer_string)
				
				if connect_fail_callback != undefined {
					connect_fail_callback()
				}
				
				net_destroy()
				
				break
			}
			
			case NetHeaders.HOST_ALLOW_CLIENT: {
				PACKET_FOR_CLIENT
				time_source_stop(connect_time_source)
				time_source_start(timeout_time_source)
				send_direct(_ip, _port, net_buffer_create(false, NetHeaders.CLIENT_SEND_INFO, buffer_string, global.config.name.value))
				
				break
			}
			
			case NetHeaders.HOST_ADD_CLIENT: {
				PACKET_FOR_CLIENT
				time_source_stop(connect_time_source)
				active = true
				local_slot = buffer_read(_buffer, buffer_u8)
				print($"net_process_packet: Assigned as Player {-~local_slot}")
				
				with net_add_player(local_slot, "127.0.0.1", 0) {
					name = global.config.name.value
					local = true
					other.local_net = self
					other.local_player = player
					player_activate(player, false)
				}
				
				repeat buffer_read(_buffer, buffer_u8) {
					var _slot = buffer_read(_buffer, buffer_u8)
					
					print($"net_process_packet: Getting info from Player {-~_slot}")
					
					with net_add_player(_slot, _slot ? "127.0.0.1" : _ip, _slot ? 0 : _port) {
						var _status = buffer_read(_buffer, buffer_u8)
						
						name = buffer_read(_buffer, buffer_string)
						
						if player != undefined {
							player.status = _status
							player_activate(player, false)
						}
					}
				}
				
				// Iterate through all players for ready and active counts
				var _players_ready = global.players_ready
				var _players_active = global.players_active
				
				ds_list_clear(_players_ready)
				ds_list_clear(_players_active)
				
				var _players = global.players
				var i = 0
				
				repeat INPUT_MAX_PLAYERS {
					var _player = _players[i++]
					
					switch _player.status {
						case PlayerStatus.PENDING: ds_list_add(_players_ready, _player) break
						case PlayerStatus.ACTIVE: ds_list_add(_players_active, _player) break
					}
				}
				
				print($"net_process_packet: {player_count} players total ({ds_list_size(_players_ready)} ready, {ds_list_size(_players_active)} active)")
				
				if connect_success_callback != undefined {
					connect_success_callback()
				}
				
				was_connected_before = true
				
				break
			}
			
			case NetHeaders.PLAYER_JOINED: {
				PACKET_FOR_CLIENT
				
				var _slot = buffer_read(_buffer, buffer_u8)
				
				if _slot == local_slot {
					break
				}
				
				var _name = buffer_read(_buffer, buffer_string) 
				
				with net_add_player(_slot, "127.0.0.1", 0) {
					name = _name
					player_activate(player, false)
				}
				
				net_say($"{_name} joined", c_yellow)
				game_update_status()
				
				break
			}
			
			case NetHeaders.HOST_DISCONNECT: {
				PACKET_FOR_CLIENT
				cmd_disconnect("")
				show_caption($"[c_red]Host disconnected")
				
				break
			}
			
			case NetHeaders.PLAYER_LEFT: {
				PACKET_FOR_CLIENT
				
				var _slot = buffer_read(_buffer, buffer_u8)
				
				if _slot == local_slot {
					net_disconnect()
					code = "NET_KICK"
					was_connected_before = true
					
					if connect_fail_callback != undefined {
						connect_fail_callback()
					}
					
					was_connected_before = false
					net_destroy()
					
					break
				}
				
				var _other = players[| _slot]
				
				if _other != undefined {
					net_say($"{_other.name} left", c_yellow)
					net_player_destroy(_other)
				}
				
				game_update_status()
				
				break
			}
			
			case NetHeaders.HOST_PING: {
				PACKET_FOR_CLIENT
				time_source_reset(timeout_time_source)
				time_source_start(timeout_time_source)
				send_direct(_ip, _port, net_buffer_create(false, NetHeaders.CLIENT_PONG))
				
				break
			}
			
			case NetHeaders.HOST_STATES_FLAGS: {
				PACKET_FOR_CLIENT
				print("net_process_packet: Received save data from host")
				
				var _players = global.players
				var n = buffer_read(_buffer, buffer_u8)
				
				repeat n {
					var _slot = buffer_read(_buffer, buffer_u8)
				
					_players[_slot].read_states(_buffer)
				}
				
				global.global_flags.read(_buffer)
				
				break
			}
			
			case NetHeaders.CLIENT_INPUT: {
				PACKET_FOR_HOST
				
				var _player = clients[? $"{_ip}:{_port}"]
				
				if _player != undefined {
					var _input_up_down = buffer_read(_buffer, buffer_s8)
					var _input_left_right = buffer_read(_buffer, buffer_s8)
					var _input_flags = buffer_read(_buffer, buffer_u8)
					var _input_aim_up_down = buffer_read(_buffer, buffer_s16)
					var _input_aim_left_right = buffer_read(_buffer, buffer_s16)
					
					ds_queue_enqueue(_player.input_queue,
						_input_up_down,
						_input_left_right,
						_input_flags,
						_input_aim_up_down,
						_input_aim_left_right
					)
				}
				
				break
			}
			
			case NetHeaders.HOST_TICK: {
				PACKET_FOR_CLIENT
				ds_queue_enqueue(tick_queue, current_time)
				
				var _pos = buffer_tell(_buffer)
				var _size = buffer_get_size(_buffer) - _pos
				var _tick = buffer_create(_size, buffer_fixed, 1)
				
				buffer_copy(_buffer, _pos, _size, _tick, 0)
				ds_queue_enqueue(tick_queue, _tick);
				++tick_count
				
				break
			}
			
			case NetHeaders.CLIENT_READY: {
				PACKET_FOR_HOST
				
				var _net = clients[? $"{_ip}:{_port}"]
				
				if _net != undefined {
					print($"net_process_packet: Got ready from Player {-~_net.slot} ({_net.name})")
					_net.ready = true
				}
				
				break
			}
			
			case NetHeaders.CLIENT_SIGNAL: {
				PACKET_FOR_HOST
				
				var _net = clients[? $"{_ip}:{_port}"]
				
				if _net != undefined {
					var _name = buffer_read(_buffer, buffer_string)
					var _slot = _net.slot
					
					print($"net_process_packet: Got signal '{_name}' from Player {-~_slot} ({_net.name})")
					
					var _tick_buffer = inject_tick_packet()
					
					buffer_write(_tick_buffer, buffer_u8, TickPackets.SIGNAL)
					buffer_write(_tick_buffer, buffer_u8, _slot)
					buffer_write(_tick_buffer, buffer_string, _name)
					
					var _argc = buffer_read(_buffer, buffer_u8)
					
					buffer_write(_tick_buffer, buffer_u8, _argc)
					
					repeat _argc {
						var _arg = buffer_read_dynamic(_buffer)
						
						buffer_write_dynamic(_tick_buffer, _arg)
					}
				}
				
				break
			}
			
			case NetHeaders.CLIENT_RENAME: {
				PACKET_FOR_HOST
				
				var _net = clients[? $"{_ip}:{_port}"]
				
				if _net == undefined {
					break
				}
				
				var _new = buffer_read(_buffer, buffer_string)
				var _old = _net.name
				
				_net.name = _new
				net_say($"{_old} is now {_new}", c_yellow)
				send_others(net_buffer_create(true, NetHeaders.PLAYER_RENAMED, buffer_u8, _net.slot, buffer_string, _new))
				
				break
			}
			
			case NetHeaders.PLAYER_RENAMED: {
				PACKET_FOR_CLIENT
				
				var _slot = buffer_read(_buffer, buffer_u8)
				var _net = players[| _slot]
				
				if _net == undefined {
					break
				}
				
				var _new = buffer_read(_buffer, buffer_string)
				var _old = _net.name
				
				_net.name = _new
				net_say($"{_old} is now {_new}", c_yellow)
				
				break
			}
			
			case NetHeaders.CLIENT_SAY: {
				PACKET_FOR_HOST
				
				var _net = clients[? $"{_ip}:{_port}"]
				
				if _net == undefined {
					break
				}
				
				var _message = buffer_read(_buffer, buffer_string)
				
				net_say($"<{_net.name}> {_message}")
				global.ui_sounds.play(global.chat_sound)
				send_others(net_buffer_create(true, NetHeaders.PLAYER_SAID, buffer_u8, _net.slot, buffer_string, _message))
				
				break
			}
			
			case NetHeaders.PLAYER_SAID: {
				PACKET_FOR_CLIENT
				
				var _slot = buffer_read(_buffer, buffer_u8)
				var _net = players[| _slot]
				
				if _net == undefined {
					break
				}
				
				var _message = buffer_read(_buffer, buffer_string)
				
				net_say($"<{_net.name}> {_message}")
				global.ui_sounds.play(global.chat_sound)
				
				break
			}
		}
	}
}