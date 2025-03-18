event_inherited()
poi_target = ThingTags.NONE
poi_lerp = 1
f_desync = true

#region Events
Camera_create = event_create
Camera_tick = event_tick

event_create = function () {
	Camera_create()
	
	if not global.game_status & GameStatus.DEMO {
		destroy(false)
		
		exit
	}
	
	if is_struct(special) {
		poi_target = force_type_fallback(special[$ "target"], "number", ThingTags.NONE)
		poi_lerp = force_type_fallback(special[$ "lerp"], "number", 1)
	}
}

event_tick = function () {
	Camera_tick()
	
	if poi_target != ThingTags.NONE {
		var _targets = area.find_tag(poi_target)
		var i = 0
		
		repeat array_length(_targets) {
			var _target = _targets[i++]
			
			if not ds_map_exists(pois, _target) {
				add_poi(_target, poi_lerp, 0, 0, _target.height * -0.5)
			}
		}
	}
}
#endregion