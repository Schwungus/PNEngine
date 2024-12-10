/// @description Create
event_inherited()

if not global.game_status & GameStatus.DEMO {
	destroy(false)
	
	exit
}

if is_struct(special) {
	poi_target = force_type_fallback(special[$ "target"], "number", ThingTags.NONE)
	poi_lerp = force_type_fallback(special[$ "lerp"], "number", 1)
}