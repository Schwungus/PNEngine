/// @param {String} args
/// @param {Bool} [loud]
/// @return {String}
function cmd_md15(_args, _loud = true) {
	var _buffer = buffer_create(1, buffer_grow, 1)
	var _mods = global.mods
	var _key = ds_map_find_first(_mods)
	
	repeat ds_map_size(_mods) {
		buffer_write(_buffer, buffer_text, _mods[? _key].md5)
		_key = ds_map_find_next(_mods, _key)
	}
	
	var _md5 = buffer_md5(_buffer, 0, buffer_tell(_buffer))
	
	buffer_delete(_buffer)
	
	if _loud {
		print(_md5)
	}
	
	return _md5
}