transition_script = undefined

reload = undefined
create = undefined
clean_up = undefined
tick = undefined
draw_screen = undefined

state = 0
to_level = undefined
to_area = 0
to_tag = ThingTags.NONE

#region Functions
is_ancestor = function (_type) {
	if is_string(_type) {
		if transition_script != undefined {
			return transition_script.is_ancestor(_type)
		}
		
		_type = asset_get_index(_type)
		
		if not object_exists(_type) {
			return false
		}
	}
	
	return object_index == _type or object_is_ancestor(object_index, _type)
}

destroy = function () {
	instance_destroy()
}

play_sound_ui = function (_sound, _loop = false, _offset = 0, _pitch = 1) {
	return global.ui_sounds.play(_sound, _loop, _offset, _pitch)
}
#endregion

#region Events
event_load = function () {}

event_create = function () {
	if reload != undefined {
		reload()
	}
	
	if create != undefined {
		catspeak_execute(create)
	}
}

event_tick = function () {
	if tick != undefined {
		catspeak_execute(tick)
	}
}

event_draw_screen = function (_width, _height) {
	if draw_screen != undefined {
		catspeak_execute(draw_screen, _width, _height)
	}
}
#endregion