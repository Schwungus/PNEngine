/// @desc Destroys a NetPlayer and returns its Player for further handling.
function net_player_destroy(_scope) {
	with _scope {
		if session != undefined {
			var _players = session.players
			
			_players[| slot] = undefined
			
			var i = ds_list_size(_players)
			
			while i {
				--i
				
				if _players[| i] != undefined {
					break
				}
				
				ds_list_delete(_players, i)
			}
			
			--session.player_count
			
			if session.master {
				ds_map_delete(session.clients, key)
			}
		}
		
		if player != undefined {
			player.net = undefined
			
			/* if player.slot != 0 {
				player_deactivate(player, false)
			} */
		}
		
		time_source_stop(reliable_time_source)
		time_source_destroy(reliable_time_source)
		
		repeat ds_map_size(reliable_read) {
			var _key = ds_map_find_first(reliable_read)
			
			buffer_delete(reliable_read[? _key])
			ds_map_delete(reliable_read, _key)
		}
		
		ds_map_destroy(reliable_read)
		
		repeat ds_map_size(reliable_write) {
			var _key = ds_map_find_first(reliable_write)
			
			buffer_delete(reliable_write[? _key])
			ds_map_delete(reliable_write, _key)
		}
		
		ds_map_destroy(reliable_write)
		ds_queue_destroy(input_queue)
		
		return player
	}
	
	return undefined
}