function player_deactivate(_scope, _loud = true) {
	with _scope {
		if status != PlayerStatus.INACTIVE {
			if slot == 0 {
				print("! player_deactivate: Player 1 cannot be deactivated")
				
				return false
			}
			
			HANDLER_FOREACH_START
				if player_deactivated != undefined {
					catspeak_execute(player_deactivated, _scope)
				}
			HANDLER_FOREACH_END
			
			if status == PlayerStatus.ACTIVE {
				var _players_active = global.players_active
				
				ds_list_delete(_players_active, ds_list_find_index(_players_active, self))
				
				if thing_exists(thing) {
					thing.destroy()
				}
				
				set_area(undefined)
				
				if _loud {
					show_caption($"[c_red]{lexicon_text("hud.caption.player.disconnect", -~slot)}")
				}
			} else {
				var _players_ready = global.players_ready
				
				ds_list_delete(_players_ready, ds_list_find_index(_players_ready, self))
				
				if _loud {
					show_caption($"[c_red]{lexicon_text("hud.caption.player.unready", -~slot)}")
				}
			}
			
			status = PlayerStatus.INACTIVE
			
			return true
		}
		
		print($"! player_deactivate: Player {-~slot} is already inactive")
		
		return false
	}
	
	print($"! player_deactivate: Scope is not a Player")
	
	return false
}