/// @param {Real} volume
function music_set_volume(_volume) {
	global.music_volume = _volume
	fmod_channel_control_set_volume(global.music_channel_group, _volume)
}