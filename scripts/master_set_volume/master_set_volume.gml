/// @param {Real} volume
function master_set_volume(_volume) {
	gml_pragma("forceinline")
	
	global.master_volume = _volume
	fmod_channel_control_set_volume(global.master_channel_group, _volume)
}