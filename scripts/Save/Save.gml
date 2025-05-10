/// @param {String} filename
function Save(_filename) constructor {
	name = string_copy(_filename, 1, string_last_pos(".", _filename) - 1)
	filename = _filename
	code = ""
	date = 0
	
	states = array_create_ext(MAX_PLAYERS, function (_index) {
		return {}
	})
	
	flags = {}
	level = ""
	area = 0
	tag = ThingTags.NONE
	
#region Validity Check
	var _buffer = buffer_load(SAVES_PATH + filename)
	
	try {
#region Header
		if buffer_read(_buffer, buffer_string) != "PNESAVE" {
			code = "SAVE_INVALID"
			print($"! Save: '{name}' has invalid header")
			buffer_delete(_buffer)
			
			exit
		}
		
		var _version = buffer_read(_buffer, buffer_string)
		
		/*if _version != GM_version {
			code = "SAVE_VERSION"
			print($"! Save: '{name}' has version mismatch ({_version} =/= {GM_version})")
			buffer_delete(_buffer)
		
			exit
		}*/
		
		date = buffer_read(_buffer, buffer_u32)
#endregion
		
#region Mods
		var _mods = global.mods
		
		repeat buffer_read(_buffer, buffer_u32) {
			var _key = buffer_read(_buffer, buffer_string)
			
			_version = buffer_read(_buffer, buffer_string)
			
			if not ds_map_exists(_mods, _key) {
				code = "SAVE_MODS"
				print($"! Save: '{name}' has missing mod '{_key}' ({_version})")
				buffer_delete(_buffer)
				
				exit
			}
			
			/*var _current_version = _mods[? _key].version
		
			if _current_version != _version {
				code = "SAVE_MODS"
				print($"! Save: '{name}' has mod '{_key}' with different version ({_version} =/= {_current_version})")
				buffer_delete(_buffer)
			
				exit
			}*/
		}
#endregion
		
#region States
		var n = buffer_read(_buffer, buffer_u8)
		
		repeat n {
			var i = buffer_read(_buffer, buffer_u8)
			
			// Skip excess player slots
			if i >= MAX_PLAYERS {
				n = buffer_read(_buffer, buffer_u32)
				
				repeat n {
					buffer_read(_buffer, buffer_string)
					buffer_read_dynamic(_buffer)
				}
				
				continue
			}
			
			var _states = states[i]
			
			n = buffer_read(_buffer, buffer_u32)
			
			repeat n {
				var _key = buffer_read(_buffer, buffer_string)
				var _value = buffer_read_dynamic(_buffer)
				
				_states[$ _key] = _value
			}
		}
#endregion
		
#region Level
		level = buffer_read(_buffer, buffer_string)
		area = buffer_read(_buffer, buffer_u32)
		tag = buffer_read(_buffer, buffer_s32)
#endregion
		
#region Flags
		n = buffer_read(_buffer, buffer_u32)
		
		repeat n {
			var _key = buffer_read(_buffer, buffer_string)
			var _value = buffer_read_dynamic(_buffer)
			
			flags[$ _key] = _value
		}
#endregion
	} catch (e) {
		code = "SAVE_UNKNOWN"
		print($"! Save: Unknown error ({e})")
	}
	
	buffer_delete(_buffer)
#endregion
}