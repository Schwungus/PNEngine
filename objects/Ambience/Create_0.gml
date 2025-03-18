event_inherited()
ambience = []
local = false

#region Events
Thing_event_load = event_load
Thing_event_create = event_create
Thing_event_tick = event_tick

event_load = function () {
	Thing_event_load()
	
	if not is_struct(special) {
		print("! Ambience.load: Special properties invalid or not found")
	
		exit
	}
	
	var _ambience = special[$ "ambience"]
	
	if not is_array(_ambience) {
		show_error($"!!! Ambience.create: Invalid ambience '{_ambience}', expected array", true)
	}
	
	var _sounds = global.sounds
	var i = array_length(_ambience)
	
	while i {
		var _ambient = _ambience[--i]
		
		if not is_struct(_ambient) {
			if is_string(_ambient) {
				_sounds.load(_ambient)
			} else {
				array_delete(_ambience, i, 1)
			}
		
			continue
		}
		
		var _sound = _ambient.sound
		
		if is_array(_sound) {
			var j = 0
			
			repeat array_length(_sound) {
				_sounds.load(_sound[j++])
			}
		} else {
			_sounds.load(_sound)
		}
	}
}

event_create = function () {
	Thing_event_create()
	
	if not is_struct(special) {
		print("! Ambience.create: Special properties invalid or not found")
		destroy(false)
	
		exit
	}
	
	var _samb = special[$ "ambience"]
	var i = array_length(_samb)
	
	array_copy(ambience, 0, _samb, 0, i)
	local = force_type_fallback(special[$ "local"], "bool", false)
	emitter_falloff = force_type_fallback(special[$ "falloff"], "number", 0)
	emitter_falloff_max = force_type_fallback(special[$ "falloff_max"], "number", 360)
	
	var _sounds = global.sounds
	
	while i {
		var _ambient = ambience[--i]
		
		if is_string(_ambient) {
			_ambient = _sounds.get(_ambient)
			
			if local {
				play_sound_local(_ambient, emitter_falloff, emitter_falloff_max, true)
			} else {
				play_sound(_ambient, true)
			}
			
			array_delete(ambience, i, 1)
			
			continue
		}
		
		var _amb = array_create(3)
		var _ssnd = _ambient.sound
		var _snd
		
		if is_array(_ssnd) {
			var j = 0
			var n2 = array_length(_ssnd)
			
			_snd = array_create(n2)
			
			repeat n2 {
				_snd[j] = _sounds.get(_ssnd[j]);
				++j
			}
		} else {
			_snd = _sounds.get(_ssnd)
		}
		
		_amb[0] = _snd
		
		var _time = _ambient.time
		
		_time = is_array(_time) ? [_time[0] * TICKRATE, _time[1] * TICKRATE] : _time * TICKRATE
		_amb[1] = _time
		ambience[i] = _amb
	}
}

event_tick = function () {
	Thing_event_tick()
	
	var i = 0
	
	repeat array_length(ambience) {
		var _amb = ambience[i++]
		
		if --_amb[2] <= 0 {
			var _time = _amb[1]
			
			_amb[2] = is_array(_time) ? irandom_range(_time[0], _time[1]) : _time
			
			if local {
				play_sound_local(_amb[0], emitter_falloff, emitter_falloff_max)
			} else {
				play_sound(_amb[0])
			}
		}
	}
}
#endregion