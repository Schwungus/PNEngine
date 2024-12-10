function area_deactivate(_scope) {
	with _scope {
		if not active {
			exit
		}
		
		if ds_list_size(players) {
			exit
		}
		
		HANDLER_FOREACH_START
			if area_deactivated != undefined {
				catspeak_execute(area_deactivated, other)
			}
		HANDLER_FOREACH_END
		
		master = undefined
		
		var _cant_deactivate = false
		var i = ds_list_size(active_things)
		
		while i {
			var _thing = active_things[| --i]
			
			if not thing_exists(_thing) {
				ds_list_delete(active_things, i)
				
				continue
			}
			
			if _thing.f_persistent {
				_thing.f_new = false
				_cant_deactivate = true
				print($"! area_deactivate: Cannot deactivate Thing {i} ({_thing.get_name()})")
				
				continue
			}
			
			_thing.destroy(false)
		}
		
		if _cant_deactivate {
			print($"! area_deactivate: Tried to deactivate area {slot} with {ds_list_size(active_things)} Things remaining")
			
			exit
		}
		
		ds_list_clear(particles)
		sounds.clear()
		active = false
	}
}