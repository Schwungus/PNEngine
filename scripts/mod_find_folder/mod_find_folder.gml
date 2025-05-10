/// @func mod_find_folder(folder)
/// @desc Finds a folder from any Mod and returns its full path.
/// @param {String} folder Folder name.
/// @return {String} Full path to the folder (empty if not found).
function mod_find_folder(_folder) {
	var _mods = global.mods
	var _key = ds_map_find_last(_mods)
	
	repeat ds_map_size(_mods) {
		var _path = _mods[? _key].path + _folder
		
		if directory_exists(_path) {
			return _path
		}
		
		_key = ds_map_find_previous(_mods, _key)
	}
	
	return ""
}