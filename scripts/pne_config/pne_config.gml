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
	vid_bloom_threshold: new CVar(0.85),
	vid_bloom_intensity: new CVar(0.2),
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
	in_mode: new CVar(2, is_numeric, function (_batch) {
		/*var _mode = INPUT_SOURCE_MODE.FIXED
		
		switch value {
			case 1: _mode = INPUT_SOURCE_MODE.JOIN break
			case 2: _mode = INPUT_SOURCE_MODE.HOTSWAP break
			case 3: _mode = INPUT_SOURCE_MODE.MIXED break
		}*/
		
		global.input_mode = 2 //_mode
		
		if not global[$ "console"] {
			//input_source_mode_set(_mode)
		}
	}),
	
	in_invert_y: new CVar(false, is_numeric, function (_batch) {
		//input_cursor_inverted_set(value, all)
	}),
	
	in_pan: new CVar(6, is_numeric, function (_batch) {
		//input_cursor_speed_set(value, all)
	}),
	
	in_mouse_pan: new CVar(0.25, is_numeric, function (_batch) {
		//input_mouse_capture_set(input_mouse_capture_get().__capture, value)
	}),
	
	in_gyro: new CVar(false),
	in_gyro_pan: new CVar(1),
}

config_load()