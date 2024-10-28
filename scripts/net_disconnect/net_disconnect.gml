/// @desc Disconnects from the current session and returns true if successful.
function net_disconnect() {
	with global.netgame {
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
			send_others(net_buffer_create(false, NetHeaders.HOST_DISCONNECT))
		} else {
			send_host(net_buffer_create(false, NetHeaders.CLIENT_DISCONNECT))
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
	
	return false
}