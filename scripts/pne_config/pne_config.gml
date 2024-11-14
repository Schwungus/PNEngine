#macro TICKRATE 30 // The update rate (base FPS) of the game
#macro TICKRATE_DELTA 0.00003 // (TICKRATE / 1000000)

#macro DATA_PATH global.config.data_path.value
#macro LOGS_PATH game_save_id + "logs/"
#macro SAVES_PATH game_save_id + "saves/"
#macro DEMOS_PATH game_save_id + "demos/"
#macro CONFIG_PATH game_save_id + "config.json"
#macro CONTROLS_PATH game_save_id + "controls.json"
global.config = {
	// DEBUG
	data_path: new CVar("data/", is_string),
	
	// USER
	name: new CVar("Player", is_string, function (_batch) {
		if not struct_exists(global, "netgame") {
			exit
		}
		
		var _netgame = global.netgame
		
		if _netgame != undefined {
			with _netgame {
				if not active or local_net == undefined {
					exit
				}
				
				var _old = local_net.name
				var _new = other.value
				
				if _old == _new {
					exit
				}
				
				if master {
					local_net.name = _new
					send_others(net_buffer_create(true, NetHeaders.PLAYER_RENAMED, buffer_u8, 0, buffer_string, _new))
					net_say($"{_old} is now {_new}", c_yellow)
				} else {
					send_host(net_buffer_create(true, NetHeaders.CLIENT_RENAME, buffer_string, other.value))
				}
			}
		}
	}),
	
	language: new CVar("English", is_string, function (_batch) {
		lexicon_language_set(value)
	}),
	
	// VIDEO
	vid_fullscreen: new CVar(false, is_numeric, function (_batch) {
		var _config = global.config
		
		display_set(value, _config.vid_width.value, _config.vid_height.value)
	}),
	
	vid_width: new CVar(960, is_numeric, function (_batch) {
		if _batch {
			exit
		}
		
		var _config = global.config
		
		display_set(_config.vid_fullscreen.value, value, _config.vid_height.value)
	}),
	
	vid_height: new CVar(540, is_numeric, function (_batch) {
		if _batch {
			exit
		}
		
		var _config = global.config
		
		display_set(_config.vid_fullscreen.value, _config.vid_width.value, value)
	}),
	
	vid_max_fps: new CVar(60, is_numeric, function (_batch) {
		game_set_speed(value, gamespeed_fps)
	}),
	
	vid_vsync: new CVar(false, is_numeric, function (_batch) {
		display_reset(global.config.vid_antialias.value, value)
	}),
	
	vid_texture_filter: new CVar(1),
	vid_mipmap_filter: new CVar(1),
	
	vid_antialias: new CVar(0, is_numeric, function (_batch) {
		if _batch {
			exit
		}
		
		display_reset(value, global.config.vid_vsync.value)
	}),
	
	vid_bloom: new CVar(true),
	vid_lighting: new CVar(1),
	
	// AUDIO
	snd_volume: new CVar(1, is_numeric, function (_batch) {
		master_set_volume(value)
	}),
	
	snd_sound_volume: new CVar(1, is_numeric, function (_batch) {
		sound_set_volume(value)
	}),
	
	snd_music_volume: new CVar(0.5, is_numeric, function (_batch) {
		music_set_volume(value)
	}),
	
	snd_background: new CVar(false),
	
	// INPUT
	in_invert_x: new CVar(false),
	in_invert_y: new CVar(false),
	in_pan_x: new CVar(6),
	in_pan_y: new CVar(6),
	in_mouse_x: new CVar(0.0125),
	in_mouse_y: new CVar(0.0125),
	
	// NETWORK
	net_interp: new CVar(0.3),
	net_interp_delay: new CVar(-1),
}

config_load()