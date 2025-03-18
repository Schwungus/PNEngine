event_inherited()
f_unique = true
finished = 0

#region Events
Thing_event_create = event_create
Thing_event_tick = event_tick

event_create = function () {
	var _level_name = level.name
	
	if _level_name != "lvlLogo" and _level_name != "lvlIntro" {
		destroy(false)
		
		exit
	}
	
	Thing_event_create()
}

event_tick = function () {
	if input_check_pressed("pause") {
		finished = 2
	}
	
	Thing_event_tick()
}
#endregion