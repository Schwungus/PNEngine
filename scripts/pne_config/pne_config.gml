#macro TICKRATE 30 // The update rate (base FPS) of the game
#macro TICKRATE_DELTA 0.00003 // (TICKRATE / 1000000)

#macro DATA_PATH global.config.data_path.value
#macro LOGS_PATH game_save_id + "logs/"
#macro SAVES_PATH game_save_id + "saves/"
#macro DEMOS_PATH game_save_id + "demos/"
#macro CONFIG_PATH game_save_id + "config.json"
#macro KEYBOARD_PATH game_save_id + "keyboard.json"
#macro GAMEPAD_PATH game_save_id + "gamepad.json"

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
	
	vid_bloom: new CVar(true, is_numeric, function (_batch) {
		if not value {
			global.bloom.clear()
		}
	}),
	
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
		InputPartySetJoin(value == 1, value == 2)
	}),
	
	in_invert_x: new CVar(false),
	in_invert_y: new CVar(false),
	in_aim_x: new CVar(6),
	in_aim_y: new CVar(6),
	
	in_mouse: new CVar(true),
	in_mouse_x: new CVar(0.1),
	in_mouse_y: new CVar(0.1),
	
	in_gyro: new CVar(false),
	in_gyro_x: new CVar(0.1),
	in_gyro_y: new CVar(0.1),
}

config_load()