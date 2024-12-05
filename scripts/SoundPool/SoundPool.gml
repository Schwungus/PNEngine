#macro SOUND_POOL_SLOTS 4

function SoundPool() constructor {
	channel_group = fmod_system_create_channel_group($"soundpool{global.last_sound_pool_id++}")
	
	gain = array_create(SOUND_POOL_SLOTS, 1)
	
	gain_start = array_create(SOUND_POOL_SLOTS, 1)
	gain_end = array_create(SOUND_POOL_SLOTS, 1)
	
	gain_time = array_create(SOUND_POOL_SLOTS, 0)
	gain_duration = array_create(SOUND_POOL_SLOTS, 0)
	
	ds_list_add(global.sound_pools, self)
	
	static play = function (_sound, _loop = false, _offset = 0, _pitch = 1, _gain = 1) {
		if _sound == undefined {
			return undefined
		}
		
		if is_array(_sound) {
			var n = array_length(_sound)
			
			return n ? play(_sound[irandom(n - 1)], _loop, _offset, _pitch) : undefined
		}
		
		var _id, _final_pitch
		
		with _sound {
			_id = asset 
			
			if is_array(_id) {
				_id = _id[irandom(array_length(_id) - 1)]
			}
			
			if _id == undefined {
				return undefined
			}
			
			_final_pitch = pitch_low == pitch_high ? pitch_low : random_range(pitch_low, pitch_high)
		}
		
		var _instance = fmod_system_play_sound(_id, true, channel_group)
		
		fmod_channel_control_set_mode(_instance, _loop ? FMOD_MODE.LOOP_NORMAL : FMOD_MODE.LOOP_OFF)
		fmod_channel_set_position(_instance, _offset, FMOD_TIMEUNIT.MS)
		fmod_channel_control_set_pitch(_instance, _pitch * _final_pitch)
		fmod_channel_control_set_volume(_instance, _gain)
		fmod_channel_control_set_paused(_instance, false)
		
		return _instance
	}
	
	static play_at = function (_sound, _x, _y, _z, _falloff_min = undefined, _falloff_max = undefined, _loop = false, _offset = 0, _pitch = 1, _gain = 1) {
		static _dummy_vel = new FmodVector()
		
		if _sound == undefined {
			return undefined
		}
		
		if is_array(_sound) {
			var n = array_length(_sound)
			
			return n ? play_at(_sound[irandom(n - 1)],  _x, _y, _z, _falloff_min, _falloff_max, _loop, _offset, _pitch) : undefined
		}
		
		var _id, _final_pitch
		
		with _sound {
			_id = asset 
			
			if is_array(_id) {
				_id = _id[irandom(array_length(_id) - 1)]
			}
			
			if _id == undefined {
				return undefined
			}
			
			_final_pitch = pitch_low == pitch_high ? pitch_low : random_range(pitch_low, pitch_high)
		}
		
		var _instance = fmod_system_play_sound(_id, true, channel_group)
		
		fmod_channel_control_set_mode(_instance, FMOD_MODE.AS_3D | FMOD_MODE.AS_3D_WORLDRELATIVE | FMOD_MODE.AS_3D_LINEARROLLOFF | (_loop ? FMOD_MODE.LOOP_NORMAL : FMOD_MODE.LOOP_OFF))
		fmod_channel_set_position(_instance, _offset, FMOD_TIMEUNIT.MS)
		fmod_channel_control_set_pitch(_instance, _pitch * _final_pitch)
		fmod_channel_control_set_volume(_instance, _gain)
		
		var _pos = { x: _x, y: _y, z: _z }
		
		fmod_channel_control_set_3d_attributes(_instance, _pos, _dummy_vel)
		
		if _falloff_min != undefined and _falloff_max != undefined {
			fmod_channel_control_set_3d_min_max_distance(_instance, _falloff_min, _falloff_max)
		}
		
		fmod_channel_control_set_paused(_instance, false)
		
		return _instance
	}
	
	static set_gain = function (_slot, _gain, _time = 0) {
		gain_time[_slot] = 0
		gain_duration[_slot] = _time
		
		if _time <= 0 {
			gain[_slot] = _gain
			fmod_channel_control_set_volume(channel_group, gain[0] * gain[1] * gain[2] * gain[3])
		}
		
		gain_start[_slot] = gain[_slot]
		gain_end[_slot] = _gain
	}
	
	static clear = function () {
		fmod_channel_control_stop(channel_group)
	}
	
	static destroy = function () {
		clear()
		fmod_channel_group_release(channel_group)
		
		var _sound_pools = global.sound_pools
		
		ds_list_delete(_sound_pools, ds_list_find_index(_sound_pools, self))
	}
}