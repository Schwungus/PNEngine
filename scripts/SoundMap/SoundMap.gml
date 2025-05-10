function SoundMap() : AssetMap() constructor {
	/// @func load(name)
	/// @desc Loads a Sound from "sounds/" and its properties if a JSON file is found.
	/// @param {String} name Sound file name.
	/// @context SoundMap
	static load = function (_name) {
		if ds_map_exists(assets, _name) {
			exit
		}
		
		var _path = "sounds/" + _name
		var _entry_file = mod_find_file(_path + ".json")
		
		if _entry_file == "" {
			// Generate a sound entry
			var _sound_file = mod_find_file(_path + ".*", ".json")
			
			if _sound_file == "" {
				print($"! SoundMap.load: '{_name}' not found")
				
				exit
			}
			
			var _sound = new Sound()
			
			_sound.name = _name
			_sound.asset = fmod_system_create_sound(_sound_file, FMOD_MODE.CREATESAMPLE)
			assets[? _name] = _sound
			print($"SoundMap.load: Added '{_name}' ({_sound})")
			
			exit
		}
		
		// Load sound entry
		var _json = json_load(_entry_file)
		
		if not is_struct(_json) {
			print($"! SoundMap.load: '{_name}' JSON root is not a struct")
			
			exit
		}
		
		var _pitch_low, _pitch_high
		var _pitch = _json[$ "pitch"]
			
		if is_array(_pitch) {
			_pitch_low = _pitch[0]
			_pitch_high = _pitch[1]
		} else {
			_pitch = force_type_fallback(_pitch, "number", 1)
			_pitch_low = _pitch
			_pitch_high = _pitch
		}
		
		var _loop_start = force_type_fallback(_json[$ "loop_start"], "number")
		var _loop_end = force_type_fallback(_json[$ "loop_end"], "number")
		var _raw = _json[$ "sound"]
		
		// Prepare Sound asset
		var _sound = new Sound()
		var _sound_file
		
		with _sound {
			name = _name
			
			if is_array(_raw) {
				var i = 0
				var n = array_length(_raw)
				
				asset = array_create(n, undefined)
				
				repeat n {
					var _variant = force_type(_raw[i], "string")
					
					_sound_file = mod_find_file("sounds/" + _variant + ".*", ".json")
					
					if _sound_file == "" {
						print($"! SoundMap.load: '{_name}': File '{_variant}' not found")
					} else {
						asset[i] = fmod_system_create_sound(_sound_file, FMOD_MODE.CREATESAMPLE)
					}
					
					++i
				}
				
				if _loop_start != undefined or _loop_end != undefined {
					print($"! SoundMap.load: '{_name}': Loop points for random sounds is not supported")
				}
			} else if is_string(_raw) {
				_sound_file = mod_find_file("sounds/" + _raw + ".*", ".json")
				
				if _sound_file == "" {
					print($"! SoundMap.load: '{_name}': File '{_raw}' not found")
				} else {
					asset = fmod_system_create_sound(_sound_file, FMOD_MODE.CREATESAMPLE)
				}
			} else {
				_sound_file = mod_find_file("sounds/" + _name + ".*", ".json")
				
				if _sound_file == "" {
					print($"! SoundMap.load: File for '{_name}' not found")
				} else {
					asset = fmod_system_create_sound(_sound_file, FMOD_MODE.CREATESAMPLE)
				}
			}
			
			pitch_low = _pitch_low
			pitch_high = _pitch_high
		}
		
		assets[? _name] = _sound
		print($"SoundMap.load: Added '{_name}' ({_sound})")
	}
}

global.sounds = new SoundMap()