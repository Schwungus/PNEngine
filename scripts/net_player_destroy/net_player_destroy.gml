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
			with player {
				net = undefined
				
				if slot != 0 {
					player_deactivate(self)
				}
			}
		}
		
		time_source_stop(reliable_time_source)
		time_source_destroy(reliable_time_source)
		
		repeat ds_list_size(reliable) {
			buffer_delete(reliable[| 0])
			ds_list_delete(reliable, 0)
		}
		
		ds_list_destroy(reliable)
		ds_queue_destroy(input_queue)
	}
}