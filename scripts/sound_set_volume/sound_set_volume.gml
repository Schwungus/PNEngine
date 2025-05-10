/// @param {Real} volume
function sound_set_volume(_volume) {
	global.sound_volume = _volume
	fmod_channel_control_set_volume(global.sound_channel_group, _volume)
}