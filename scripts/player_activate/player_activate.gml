function player_activate(_scope) {
	with _scope {
		if status == PlayerStatus.INACTIVE {
			status = PlayerStatus.PENDING
			
			var _device
			
			if net_active() {
				_device = "remote"
			} else {
				_device = input_player_get_gamepad_type(slot)
				
				if _device == "unknown" {
					_device = "no controller"
				}
			}
			
			ds_list_add(global.players_ready, self)
			show_caption($"[c_lime]{lexicon_text("hud.caption.player.ready", -~slot)} ({_device})")
			
			return true
		}
		
		print($"! player_activate: Player {slot} is already ready/active")
		
		return false
	}
	
	print($"! player_activate: Scope is not a Player")
	
	return false
}