/// @description Create
event_inherited()

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
	
	if is_array(_time) {
		_time = [_time[0] * TICKRATE, _time[1] * TICKRATE]
	} else {
		_time *= TICKRATE
	}
	
	_amb[1] = _time
	ambience[i] = _amb
}