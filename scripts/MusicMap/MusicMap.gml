function MusicMap() : AssetMap() constructor {
	/// @func load(name)
	/// @desc Loads Music from "music/" and its properties if a JSON file is found.
	/// @param {String} name Music file name.
	/// @context MusicMap
	static load = function (_name) {
		static _no_metadata = {}
		
		if ds_map_exists(assets, _name) {
			exit
		}
		
		var _path = "music/" + _name
		var _music_file = mod_find_file(_path + ".*", ".json")
		
		if _music_file != "" {
			var _loop_start = undefined
			var _loop_end = undefined
			var _cut_in = 0
			var _cut_out = 0
			var _fade_in = 0
			var _fade_out = 0
			var _metadata = _no_metadata
			var _json = json_load(mod_find_file(_path + ".json"))
			
			if is_struct(_json) {
				_loop_start = _json[$ "loop_start"]
				_loop_end = _json[$ "loop_end"]
				_metadata = _json[$ "metadata"] ?? _no_metadata
				
				var _cut = _json[$ "cut"]
				
				if is_array(_cut) {
					var n = array_length(_cut)
					
					_cut_in = n >= 1 ? _cut[0] : 0
					_cut_out = n >= 2 ? _cut[1] : 0
				}
				
				var _fade = _json[$ "fade"]
				
				if is_array(_fade) {
					var n = array_length(_fade)
					
					_fade_in = n >= 1 ? _fade[0] : 0
					_fade_out = n >= 2 ? _fade[1] : 0
				}
			}
			
			var _stream = fmod_system_create_stream(_music_file, FMOD_MODE.ACCURATETIME)
			
			if is_real(_loop_start) or is_real(_loop_end) {
				fmod_sound_set_loop_points(_stream, _loop_start ?? 0, FMOD_TIMEUNIT.PCM, _loop_end ?? fmod_sound_get_length(_stream, FMOD_TIMEUNIT.PCM), FMOD_TIMEUNIT.PCM)
			}
			
			var __music = new Music()
			
			with __music {
				name = _name
				stream = _stream
				cut_in = _cut_in
				cut_out = _cut_out
				fade_in = _fade_in
				fade_out = _fade_out
				metadata = _metadata
			}
			
			ds_map_add(assets, _name, __music)
			print($"MusicMap.load: Added '{_name}' ({__music})")
		} else {
			print($"! MusicMap.load: '{_name}' not found")
		}
	}
}

global.music = new MusicMap()