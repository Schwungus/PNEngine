#macro TICKRATE 30 // The update rate (base FPS) of the game
#macro TICKRATE_DELTA 0.00003 // (TICKRATE / 1000000)

#macro DATA_PATH global.config.data_path
#macro LOGS_PATH game_save_id + "logs/"
#macro SAVES_PATH game_save_id + "saves/"
#macro DEMOS_PATH game_save_id + "demos/"
#macro CONFIG_PATH game_save_id + "config.json"
#macro CONTROLS_PATH game_save_id + "controls.json"

global.config_trigger = {
	// DEBUG
	data_path: is_string,
	
	// USER
	name: function (_value) {
		if not is_string(_value) {
			return false
		}
		
		if not struct_exists(global, "netgame") {
			return true
		}
		
		var _netgame = global.netgame
		
		if _netgame != undefined {
			with _netgame {
				if not active {
					break
				}
				
				if master {
					local_net.name = _value
					send_others(net_buffer_create(true, NetHeaders.PLAYER_RENAMED, buffer_u8, 0, buffer_string, _value))
					net_say($"{global.config.name} is now {_value}", c_yellow)
				} else {
					send_host(net_buffer_create(true, NetHeaders.CLIENT_RENAME, buffer_string, _value))
				}
			}
		}
		
		return true
	},
	
	language: is_string,
	vid_fullscreen: is_numeric,
	vid_width: is_numeric,
	vid_height: is_numeric,
	vid_max_fps: is_numeric,
	vid_vsync: is_numeric,
	vid_texture_filter: is_numeric,
	vid_mipmap_filter: is_numeric,
	vid_antialias: is_numeric,
	vid_bloom: is_numeric,
	vid_lighting: is_numeric,
	snd_volume: is_numeric,
	snd_sound_volume: is_numeric,
	snd_music_volume: is_numeric,
	snd_background: is_numeric,
	in_invert_x: is_numeric,
	in_invert_y: is_numeric,
	in_pan_x: is_numeric,
	in_pan_y: is_numeric,
	in_mouse_x: is_numeric,
	in_mouse_y: is_numeric,
	net_interp: is_numeric,
	net_interp_delay: is_numeric,
}

global.config_refresh = {
	language: true,
	vid_fullscreen: true,
	vid_width: true,
	vid_height: true,
	vid_max_fps: true,
	vid_vsync: true,
	vid_antialias: true,
}

config_load()