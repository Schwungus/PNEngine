/// @func console_save(prefix, [context])
/// @desc Saves the console log to a text file with a prefix and optional context.
/// @return {String} The filename.
function console_save(_prefix, _context = "") {
	var _filename = $"{_prefix}_{date_datetime_string(date_current_datetime())}.txt"
	
	_filename = string_replace_all(_filename, "/", ".")
	_filename = string_replace_all(_filename, ":", ".")
	print($"console_save: Saved console output to '{_filename}'")
	
	var _log = buffer_create(1, buffer_grow, 1)
	
#region User Details
	// Game
	buffer_write(_log, buffer_text, "[PNENGINE]\n\n")
	buffer_write(_log, buffer_text, "Executable Version: " + GM_version + "\n")
	buffer_write(_log, buffer_text, "Runtime Version: " + GM_runtime_version + "\n")
	buffer_write(_log, buffer_text, "Build Date: " + date_datetime_string(GM_build_date) + "\n")
	
	var _build_type = "GMS2 " + (code_is_compiled() ? "YYC" : "VM")
	
	if debug_mode {
		_build_type += ", Debug Mode"
	}
	
	buffer_write(_log, buffer_text, "Build Type: " + GM_build_type + " (" + _build_type + ")\n\n")
	buffer_write(_log, buffer_text, "Mods:\n")
	
	var _mods = global.mods
	var _key = ds_map_find_first(_mods)
	
	repeat ds_map_size(_mods) {
		buffer_write(_log, buffer_text, $"{_mods[? _key].name} ({_key})\n")
		_key = ds_map_find_next(_mods, _key)
	}
	
	buffer_write(_log, buffer_text, "\n")
	
	// Operating System
	var _os
	
	switch os_type {
		case os_windows:
			_os = "Windows"
			
			switch os_version {
				case 327680: _os += " 2000" break
				case 327681:
				case 237862: _os += " XP" break
				case 393216: _os += " Vista" break
				case 393217: _os += " 7" break
				case 393218: _os += " 8" break
				case 393219: _os += " 8.1" break 
				case 655360: _os += " 10" break
			}
			
			break
			
		case os_linux: _os = "Linux" break
		case os_macosx: _os = $"macOS {os_version >> 24}.{(os_version >> 12) & 0xfff}" break
		default: _os = $"Unknown or Unsupported ({os_type})"
	}
	
	buffer_write(_log, buffer_text, $"OS Name: {_os}\n")
	buffer_write(_log, buffer_text, $"OS Version: {os_version}\n")
	
	var _os_info = {}
	var _os_info_map = os_get_info()
	var _os_info_keys = ds_map_keys_to_array(_os_info_map)
	var _os_info_values = ds_map_values_to_array(_os_info_map)
	
	repeat ds_map_size(_os_info_map) {
		_os_info[$ array_pop(_os_info_keys)] = array_pop(_os_info_values)
	}
	
	ds_map_destroy(_os_info_map)
	buffer_write(_log, buffer_text, "OS Info: " + json_stringify(_os_info, true) + "\n\n")
	buffer_write(_log, buffer_text, $"Frame Start Time: {current_time} ms\n")
	buffer_write(_log, buffer_text, $"Elapsed Time: {get_timer()} us\n\n")
#endregion
	
#region Context
	if _context != "" {
		buffer_write(_log, buffer_text, _context + "\n\n")
	}
#endregion
	
#region Console Output
	var _console_log = global.console_log
	var i = 0
	
	repeat ds_list_size(_console_log) {
		buffer_write(_log, buffer_text, _console_log[| i++] + "\n")
	}
	
	buffer_save(_log, LOGS_PATH + _filename)
	buffer_delete(_log)
#endregion
	
	return _filename
}