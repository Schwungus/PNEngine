function player_activate(_scope) {
	with _scope {
		if status == PlayerStatus.INACTIVE {
			status = PlayerStatus.PENDING
			
			var _device = input_player_get_gamepad_type(slot)
			
			if _device == "unknown" {
				_device = "no controller"
			}
			
			++global.players_ready;
			show_caption($"[c_lime]{lexicon_text("hud.caption.player.ready", -~slot)} ({_device})")
			
			if global.demo_write {
				var _demo_buffer = global.demo_buffer
				
				if _demo_buffer != undefined {
					buffer_write(_demo_buffer, buffer_u32, global.demo_time)
					buffer_write(_demo_buffer, buffer_u8, DemoPackets.PLAYER_ACTIVATE)
					buffer_write(_demo_buffer, buffer_u8, slot)
					buffer_write(_demo_buffer, buffer_u8, DemoPackets.TERMINATE)
				}
			}
			
			return true
		}
		
		print($"! player_activate: Player {slot} is already ready/active")
		
		return false
	}
	
	print($"! player_activate: Scope is not a Player")
	
	return false
}