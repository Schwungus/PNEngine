function player_activate(_scope, _loud = true) {
	with _scope {
		if status == PlayerStatus.INACTIVE {
			status = PlayerStatus.PENDING
			
			if _loud {
				var _device = input_player_get_gamepad_type(slot)
				
				if _device == "unknown" {
					_device = "no gamepad"
				}
				
				show_caption($"[c_lime]{lexicon_text("hud.caption.player.ready", -~slot)} ({_device})")
			}
			
			ds_list_add(global.players_ready, self)
			
			HANDLER_FOREACH_START
				if player_activated != undefined {
					catspeak_execute(player_activated, _scope)
				}
			HANDLER_FOREACH_END
			
			return true
		}
		
		print($"! player_activate: Player {-~slot} is already ready/active")
		
		return false
	}
	
	print($"! player_activate: Scope is not a Player")
	
	return false
}