/// @func music_play(music, priority, [loop], [gain], [offset], [active])
/// @desc Plays Music as a MusicInstance.
/// @param {Struct.Music} music Music to play.
/// @param {Real} priority Priority to play at. Higher values will fade out lower instances.
/// @param {Bool} [loop] Whether to loop or not.
/// @param {Real} [gain] Instance volume.
/// @param {Real} [offset] Music position in samples.
/// @param {Bool} [active] Whether or not the instance is active.
/// @return {Struct.MusicInstance|Undefined} Music instance (undefined if unsuccessful).
function music_play(_music, _priority, _loop = true, _gain = 1, _offset = 0, _active = true) {
	gml_pragma("forceinline")
	
	if not is_instanceof(_music, Music) {
		return undefined
	}
	
	return new MusicInstance(_music, _priority, _loop, _gain, _offset, _active)
}