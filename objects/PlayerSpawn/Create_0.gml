event_inherited()
f_visible = false

#region Events
Thing_event_load = event_load

event_load = function () {
	Thing_event_load()
	
	var _type = force_type_fallback(global.local_flags.get("player_class"), "string")
	
	if _type == undefined {
		_type = force_type(global.global_flags.get("player_class"), "string")
	}
	
	thing_load(_type, special)
	
	var _players = global.players
	var i = 0
	
	repeat MAX_PLAYERS {
		var _player = _players[i++]
		
		if _player.status == PlayerStatus.INACTIVE {
			continue
		}
		
		var _class = force_type_fallback(_player.get_state("player_class"), "string")
		
		if _class != undefined {
			thing_load(_class, special)
		}
	}
}
#endregion