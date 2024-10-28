function player_deactivate(_scope) {
	with _scope {
		if status != PlayerStatus.INACTIVE {
			var _in_area = false
			
			if status == PlayerStatus.ACTIVE {
				if global.players_active <= 1 {
					print("! Player.deactivate: Cannot deactivate with one player remaining")
					
					return false
				}
				
				--global.players_active;
				
				if instance_exists(thing) {
					thing.destroy()
				}
				
				_in_area = true
				show_caption($"[c_red]{lexicon_text("hud.caption.player.disconnect", -~slot)}")
			} else {
				--global.players_ready;
				show_caption($"[c_red]{lexicon_text("hud.caption.player.unready", -~slot)}")
			}
			
			status = PlayerStatus.INACTIVE
			
			if _in_area {
				set_area(undefined)
			}
			
			if global.demo_write {
				var _demo_buffer = global.demo_buffer
				
				if _demo_buffer != undefined {
					buffer_write(_demo_buffer, buffer_u32, global.demo_time)
					buffer_write(_demo_buffer, buffer_u8, DemoPackets.PLAYER_DEACTIVATE)
					buffer_write(_demo_buffer, buffer_u8, slot)
					buffer_write(_demo_buffer, buffer_u8, DemoPackets.TERMINATE)
				}
			}
			
			return true
		}
		
		print("! Player.deactivate: Player is already inactive")
		
		return false
	}
	
	print($"! player_deactivate: Scope is not a Player")
	
	return false
}