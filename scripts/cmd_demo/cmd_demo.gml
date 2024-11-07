function cmd_demo(_args) {
	var _parse_args = string_split(_args, " ", true)
	var n = array_length(_parse_args)
	
	if n == 0 {
		print("Usage: demo <filename>")
		
		exit
	}
	
	CMD_NO_NETGAME
	
	var _filename = _parse_args[0] + ".pnd"
	var _path = DEMOS_PATH + _filename
	
	if not file_exists(_path) {
		print($"! cmd_demo: '{_filename}' not found")
		
		exit
	}
	
	if global.demo_write {
		print("! cmd_demo: Cannot play demo while recording")
		
		exit
	}
	
	cmd_dend("")
	
	var _demo_buffer = buffer_load(_path)
	
	// Header
	if buffer_read(_demo_buffer, buffer_string) != "PNEDEMO" {
		buffer_delete(_demo_buffer)
		print($"! cmd_demo: '{_filename}' is not a demo")
		
		exit
	}
	
	// Version
	var _gmver = buffer_read(_demo_buffer, buffer_string)
	
	if _gmver != GM_version {
		print($"! cmd_demo: Demo version '{_gmver}' does not match game version '{GM_version}'. Expect desyncs to happen!")
	}
	
	var _is_netgame = buffer_read(_demo_buffer, buffer_u8)
	
	global.demo_client = _is_netgame > 1
	
	// Mods
	var _mods = global.mods
	
	n = ds_map_size(_mods)
	
	var _demo_mods = buffer_read(_demo_buffer, buffer_u32)
	
	repeat _demo_mods {
		var _name = buffer_read(_demo_buffer, buffer_string)
		var _version = buffer_read(_demo_buffer, buffer_string)
		
		if not ds_map_exists(_mods, _name) {
			buffer_delete(_demo_buffer)
			print($"! cmd_demo: '{_filename}' requires the mod '{_name}' ({_version})")
			
			exit
		}
		
		var _my_version = _mods[? _name].version
		
		if _version != _my_version {
			buffer_delete(_demo_buffer)
			print($"! cmd_demo: '{_filename}' mod '{_name}' requires version '{_version}', currently using '{_my_version}'")
			
			exit
		}
	}
	
	if _demo_mods != n {
		buffer_delete(_demo_buffer)
		print($"! cmd_demo: '{_filename}' has {_demo_mods} mod(s) while {n} mod(s) are loaded")
		
		exit
	}
	
	// States
	var _max_players = buffer_read(_demo_buffer, buffer_u8)
	var _players = global.players
	
	repeat _max_players {
		var _slot = buffer_read(_demo_buffer, buffer_u8)
		
		if _slot >= INPUT_MAX_PLAYERS {
			buffer_delete(_demo_buffer)
			print($"! cmd_demo: '{_filename}' has invalid player index {_slot}")
			
			exit
		}
		
		with _players[_slot] {
			var _status = buffer_read(_demo_buffer, buffer_u8)
			
			if _status != PlayerStatus.INACTIVE {
				player_activate(self)
			}
			
			read_states(_demo_buffer)
		}
	}
	
	// Level & flags
	var _level = buffer_read(_demo_buffer, buffer_string)
	var _area = buffer_read(_demo_buffer, buffer_u32)
	var _tag = buffer_read(_demo_buffer, buffer_s32)
	
	global.flags[FlagGroups.GLOBAL].read(_demo_buffer)
	global.demo_buffer = _demo_buffer
	global.game_status = GameStatus.DEMO
	
	if _is_netgame {
		global.game_status |= GameStatus.NETGAME
	}
	
	global.save_name = "Demo"
	global.level.goto(_level, _area, _tag)
}