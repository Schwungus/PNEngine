function player_deactivate(_scope, _loud = true) {
	with _scope {
		if status != PlayerStatus.INACTIVE {
			if slot == 0 {
				print("! Player.deactivate: Player 1 cannot be deactivated")
				
				return false
			}
			
			var _in_area = false
			
			if status == PlayerStatus.ACTIVE {
				var _players_active = global.players_active
				
				/*if ds_list_size(_players_active) <= 1 {
					print("! Player.deactivate: Cannot deactivate with one player remaining")
					
					return false
				}*/
				
				ds_list_delete(_players_active, ds_list_find_index(_players_active, self))
				
				if instance_exists(thing) {
					thing.destroy()
				}
				
				_in_area = true
				
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
			
			if _in_area {
				set_area(undefined)
			}
			
			return true
		}
		
		print("! Player.deactivate: Player is already inactive")
		
		return false
	}
	
	print($"! player_deactivate: Scope is not a Player")
	
	return false
}