/// @func MusicInstance(music, priority, [loop], [gain], [offset], [active])
/// @param {Struct.Music} music Music to play.
/// @param {Real} priority Priority to play at. Higher values will fade out lower instances.
/// @param {Bool} [loop] Whether to loop or not.
/// @param {Real} [gain] Instance volume.
/// @param {Real} [offset] Music position in samples.
/// @param {Bool} [active] Whether or not the instance is active.
function MusicInstance(_music, _priority, _loop = true, _gain = 1, _offset = 0, _active = true) constructor {
	stopping = false
	
	music = _music
	priority = _priority
	loop = _loop
	active = _active
	
	// 0 = main, 1 = cut, 2 = fade, 3 = game
	gain = [_gain, 1, _active, 1]
	gain_start = [_gain, 1, _active, 1]
	gain_end = [_gain, 1, _active, 1]
	gain_time = [0, 0, 0, 0]
	gain_duration = [0, 0, 0, 0]
	
	ds_list_add(global.music_instances, self)
	
	sound_instance = fmod_system_play_sound(_music.stream, true, global.music_channel_group)
	fmod_channel_control_set_mode(sound_instance, _loop ? FMOD_MODE.LOOP_NORMAL : FMOD_MODE.LOOP_OFF)
	fmod_channel_control_set_volume(sound_instance, gain[0] * gain[1] * gain[2] * gain[3])
	fmod_channel_set_position(sound_instance, _offset, FMOD_TIMEUNIT.PCM)
	
	/// @func set_gain(gain, [time])
	/// @desc Sets the volume.
	/// @param {Real} gain Target volume.
	/// @param {Real} [time] Fading time in milliseconds.
	/// @context MusicInstance
	static set_gain = function (_gain, _time = 0) {
		gml_pragma("forceinline")
		
		set_gain_common(0, _gain, _time)
	}
	
	/// @param {Real} slot
	/// @param {Real} gain
	/// @param {Real} [time]
	/// @context MusicInstance
	static set_gain_common = function (_slot, _gain, _time = 0) {
		if _slot == 2 and stopping {
			exit
		}
		
		gain_time[_slot] = 0
		gain_duration[_slot] = _time
		
		if _time <= 0 {
			gain[_slot] = _gain
			fmod_channel_control_set_volume(sound_instance, gain[0] * gain[1] * gain[2] * gain[3])
			
			exit
		}
		
		gain_start[_slot] = gain[_slot]
		gain_end[_slot] = _gain
	}
	
	/// @func set_position(position)
	/// @desc Seeks to the specified position.
	/// @param {Real} position Target position in samples.
	/// @context MusicInstance
	static set_position = function (_position) {
		fmod_channel_set_position(sound_instance, _position, FMOD_TIMEUNIT.PCM)
	}
	
	if _active {
		var _music_priority = global.music_priority
		var _last_top = ds_priority_find_max(_music_priority)
		
		ds_priority_add(_music_priority, self, _priority)
		
		if ds_priority_find_max(_music_priority) == self {
			if _last_top != undefined {
				_last_top.set_gain_common(1, 0, _music.cut_out)
			}
		} else {
			set_gain_common(1, 0, 0)
		}
	}
	
	fmod_channel_control_set_paused(sound_instance, false)
	
	/// @func set_active(active)
	/// @desc Whether to activate or deactivate the instance.
	///       When deactivated, lower priority tracks will fade back in.
	/// @param {Bool} active
	/// @context MusicInstance
	static set_active = function (_active) {
		if active == _active {
			return false
		}
		
		active = _active
		
		var _music_priority = global.music_priority
		
		if _active {
			var _last_top = ds_priority_find_max(_music_priority)
			
			ds_priority_add(_music_priority, self, priority)
			
			if ds_priority_find_max(_music_priority) == self {
				if _last_top != undefined {
					_last_top.set_gain_common(1, 0, music.cut_out)
				}
			} else if _last_top != undefined {
				set_gain_common(1, 0, gain[2] > 0 ? _last_top.music.cut_out : 0)
			}
			
			set_gain_common(2, 1, music.fade_in)
		} else {
			set_gain_common(2, 0, music.fade_out)
			ds_priority_delete_value(_music_priority, self)
			
			var _top = ds_priority_find_max(_music_priority)
			
			if _top != undefined {
				_top.set_gain_common(1, 1, music.cut_in)
			}
		}
		
		return true
	}
	
	/// @func stop([fade])
	/// @desc Stops and eventually destroys the instance.
	/// @param {Bool} [fade] Whether or not the music should fade out before stopping.
	/// @context MusicInstance
	static stop = function (_fade = false) {
		if _fade {
			set_gain_common(2, 0, music.fade_out)
		} else {
			destroy()
		}
		
		stopping = true
	}
	
	static destroy = function () {
		if fmod_channel_control_is_playing(sound_instance) {
			fmod_channel_control_stop(sound_instance)
		}
		
		var _music_priority = global.music_priority
		
		ds_priority_delete_value(_music_priority, self)
		
		var _top = ds_priority_find_max(_music_priority)
		
		if _top != undefined {
			_top.set_gain_common(1, 1, music.cut_in)
		}
		
		var _music_instances = global.music_instances
		
		ds_list_delete(_music_instances, ds_list_find_index(_music_instances, self))
	}
}