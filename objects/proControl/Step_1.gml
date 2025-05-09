steam_update()

switch load_state {
	case LoadStates.START: {
		load_state = LoadStates.UNLOAD
		
		exit
	}
	
	case LoadStates.UNLOAD: {
		with proTransition {
			if state == 3 {
				instance_destroy()
			}
		}
		
		var _ui = global.ui
		
		if _ui != undefined {
			_ui.destroy()
		}
		
		var _canvases = global.canvases
		var i = 0
		
		repeat array_length(_canvases) {
			_canvases[i++].Flush()
		}
		
		global.ui_sounds.clear()
		
		var _music_instances = global.music_instances
		
		repeat ds_list_size(_music_instances) {
			_music_instances[| 0].destroy()
		}
		
		level_destroy(global.level)
		
		var _players = global.players
		
		i = 0
		
		repeat MAX_PLAYERS {
			with _players[i++] {
				level = undefined
				area = undefined
				thing = noone
				camera = noone
			}
		}
		
		global.images.clear()
		global.materials.clear()
		global.models.clear()
		global.animations.clear()
		global.fonts.clear()
		global.sounds.clear()
		global.music.clear()
		
		if load_level == undefined {
			game_end()
			
			exit
		}
		
		global.local_flags.clear()
		global.level = new Level()
		catspeak_collect()
		gc_collect()
		load_state = LoadStates.LOAD
		
		exit
	}
	
	case LoadStates.LOAD: {
		print($"\n========== {load_level} ({lexicon_text("level." + load_level)}) ==========")
		print($"(Entering area {load_area} from {load_tag})")
		
		var _images = global.images
		
		_images.start_batch()
		
		var _level = global.level
		
		_level.name = load_level
		
		var _json = json_load(mod_find_file("levels/" + load_level + ".*"))
		
		if not is_struct(_json) {
			show_error($"!!! proControl: '{load_level}' not found", true)
		} else {
			if load_level == "lvlLogo" or load_level == "lvlTitle" {
				if global.demo_write {
					if global.demo_buffer != undefined {
						var _filename = "demo_" + string_replace_all(date_datetime_string(date_current_datetime()), "/", ".")
						
						cmd_dend(_filename)
						show_caption($"[c_red]Recording ended on title.\nSaved as '{_filename}.pnd'.")
					} else {
						cmd_dend("")
						show_caption("[c_red]Recording cancelled by title.")
					}
				} else if global.demo_buffer != undefined {
					cmd_dend("")
					show_caption("[c_red]Demo ended on title.")
				}
			}
			
			global.rng_game.state = 0
			
#region Discord Rich Presence
			_level.rp_name = force_type_fallback(_json[$ "rp_name"], "string", "")
			_level.rp_icon = force_type_fallback(_json[$ "rp_icon"], "string", "")
			_level.rp_time = force_type_fallback(_json[$ "rp_time"], "bool", false)
#endregion
			
#region Default Properties
			if force_type_fallback(_json[$ "checkpoint"], "bool", false) {
				var _checkpoint = global.checkpoint
				
				_checkpoint[0] = load_level
				_checkpoint[1] = load_area
				_checkpoint[2] = load_tag
				save_game()
			}
			
			var _music_tracks = _json[$ "music"]
			
			if _music_tracks != undefined {
				var _music = global.music
				
				if is_string(_music_tracks) {
					_level.music = [_music_tracks]
				} else if is_array(_music_tracks) {
					var i = 0
					
					repeat array_length(_music_tracks) {
						var _track = _music_tracks[i]
						var _name
						
						if is_string(_track) {
							_name = _track
						} else {
							if is_struct(_track) {
								_name = _track[$ "name"]
								
								if not is_string(_name) {
									show_error($"!!! proControl: Level has invalid info for music track {i}, struct must have a 'name' member with string", true)
								}
							} else {
								show_error($"!!! proControl: Level has invalid info for music track {i}, expected string or struct", true)
							}
						}
						
						++i
					}
					
					_level.music = _music_tracks
				} else {
					show_error($"!!! proControl: Level has invalid info for music, expected string or array", true)
				}
			} else {
				_level.music = []
			}
			
			with _level {
				clear_color = color_to_vec5(_json[$ "clear_color"], c_black)
				
				var _fog_distance = _json[$ "fog_distance"]
				
				fog_distance = is_array(_fog_distance) ? [real(_fog_distance[0]), real(_fog_distance[1])] : [0, 65535]
				fog_color = color_to_vec5(_json[$ "fog_color"])
				ambient_color = color_to_vec5(_json[$ "ambient_color"])
				wind_strength = force_type_fallback(_json[$ "wind_strength"], "number", 1)
				
				var _wind_direction = _json[$ "wind_direction"]
				
				wind_direction = is_array(_wind_direction) ? [real(_wind_direction[0]), real(_wind_direction[1]), real(_wind_direction[2])] : [1, 1, 1]
				gravity = force_type_fallback(_json[$ "gravity"], "number", 0.3)
			}
#endregion
			
			var _copy_flags = force_type_fallback(_json[$ "flags"], "struct")
			
			if _copy_flags != undefined {
				var _copy_global = force_type_fallback(_copy_flags[$ "global"], "struct")
				
				if _copy_global != undefined {
					global.global_flags.copy(_copy_global)
				}
				
				var _copy_local = force_type_fallback(_copy_flags[$ "local"], "struct")
				
				if _copy_local != undefined {
					global.local_flags.copy(_copy_local)
				}
			}
			
#region Assets
			var _assets = force_type_fallback(_json[$ "assets"], "struct")
			
			if _assets != undefined {
				// Images
				var __images = _assets[$ "images"]
				
				if __images != undefined {
					repeat array_length(__images) {
						_images.load(array_pop(__images))
					}
				}
				
				// Materials
				var __materials = _assets[$ "materials"]
					
				if __materials != undefined {
					var _materials = global.materials
					
					repeat array_length(__materials) {
						_materials.load(array_pop(__materials))
					}
				}
				
				// Models
				var __models = _assets[$ "models"]
				
				if __models != undefined {
					var _models = global.models
					
					repeat array_length(__models) {
						_models.load(array_pop(__models))
					}
				}
				
				// Fonts
				var __fonts = _assets[$ "fonts"]
				
				if __fonts != undefined {
					var _fonts = global.fonts
					
					repeat array_length(__fonts) {
						_fonts.load(array_pop(__fonts))
					}
				}
				
				// Sounds
				var __sounds = _assets[$ "sounds"]
				
				if __sounds != undefined {
					var _sounds = global.sounds
					
					repeat array_length(__sounds) {
						_sounds.load(array_pop(__sounds))
					}
				}
				
				// Music
				var __music = _assets[$ "music"]
				
				if __music != undefined {
					var _music = global.music
					
					repeat array_length(__music) {
						_music.load(array_pop(__music))
					}
				}
				
				// Things
				var _things = _assets[$ "things"]
				
				if _things != undefined {
					repeat array_length(_things) {
						var _thing = array_pop(_things)
						var _thing_index = asset_get_index(_thing)
						
						if _thing_index != -1 {
							if string_starts_with(_thing, "pro") {
								print($"! proControl: Can't load protected Thing '{_thing}'!")
								
								continue
							}
							
							thing_load(_thing_index)
						} else {
							thing_load(_thing)
						}
					}
				}
			}
#endregion
			
#region Areas
			var _add_areas = _json[$ "areas"]
			
			if not is_array(_add_areas) {
				show_error($"!!! proControl: Level '{load_level}' has no areas", true)
			} else {
				var _thing_slot = 0
				
				var _areas = _level.areas
				var _models = global.models
				var _scripts = global.scripts
				
				var _current_area_pos = 0
				
				repeat array_length(_add_areas) {
					var _area = new Area()
					var _area_info = _add_areas[_current_area_pos++]
					
					// Check for valid ID
					var _id = _area_info[$ "id"]
					
					if is_real(_id) {
						if _id < 0 {
							show_error($"!!! proControl: Invalid area ID '{_id}', must be 0 or greater", true)
						}
						
						_id = floor(_id)
						
						if ds_map_exists(_areas, _id) {
							show_error($"!!! proControl: Area ID '{_id}' is already defined", true)
						}
						
						with _area {
							level = _level
							slot = _id
							ds_map_add(_areas, _id, _area)
							
							var _clear_color = _area_info[$ "clear_color"]
							var _ambient_color = _area_info[$ "ambient_color"]
							var _fog_distance = _area_info[$ "fog_distance"]
							var _fog_color = _area_info[$ "fog_color"]
							var _wind_direction = _area_info[$ "wind_direction"]
							
							clear_color = _clear_color == undefined ? _level.clear_color : color_to_vec5(_clear_color)
							ambient_color = _ambient_color == undefined ? _level.ambient_color : color_to_vec5(_ambient_color)
							fog_distance = is_array(_fog_distance) ? [real(_fog_distance[0]), real(_fog_distance[1])] : _level.fog_distance
							fog_color = _fog_color == undefined ? _level.fog_color : color_to_vec5(_fog_color)
							wind_strength = force_type_fallback(_area_info[$ "wind_strength"], "number", _level.wind_strength)
							wind_direction = _wind_direction == undefined ? _level.wind_direction : [real(_wind_direction[0]), real(_wind_direction[1]), real(_wind_direction[2])]
							gravity = force_type_fallback(_area_info[$ "gravity"], "number", _level.gravity)
						}
						
						// Check for model
						var _model_name = _area_info[$ "model"]
						
						if is_string(_model_name) {
							var _model = _models.fetch(_model_name)
							
							if _model != undefined {
								_area.model = new ModelInstance(_model)
								
								var _collider = _model.collider
								
								if _collider != undefined {
									_area.collider = new ColliderInstance(_collider)
								}
							}
						}
						
						// Check for things
						var _things = _area.things
						var _add_things = _area_info[$ "things"]
						var _bump_x1 = infinity
						var _bump_y1 = infinity
						var _bump_x2 = -infinity
						var _bump_y2 = -infinity
						
						if is_array(_add_things) {
							_models.load("mdlShadow")
							
							var i = 0
							
							repeat array_length(_add_things) {
								var _area_thing = new AreaThing()
								var _thing_info = _add_things[i]
								
								with _area_thing {
									level = _level
									area = _area
									slot = _thing_slot
									
									var _type_name = _thing_info[$ "type"]
									
									type = asset_get_index(_type_name)
									
									if type == -1 {
										type = _type_name
									}
									
									if string_starts_with(_type_name, "pro") {
										print($"! proControl: Can't load protected Thing '{_type_name}' in area {_id}!")
										
										delete _area_thing
									} else {
										var _special = _thing_info[$ "special"]
										
										if thing_load(type, _special) {
											x = force_type_fallback(_thing_info[$ "x"], "number", 0)
											y = force_type_fallback(_thing_info[$ "y"], "number", 0)
											z = force_type_fallback(_thing_info[$ "z"], "number", 0)
											
											var _bx = floor(x * COLLIDER_REGION_SIZE_INVERSE) * COLLIDER_REGION_SIZE
											var _by = floor(y * COLLIDER_REGION_SIZE_INVERSE) * COLLIDER_REGION_SIZE
											
											_bump_x1 = min(_bump_x1, _bx)
											_bump_y1 = min(_bump_y1, _by)
											_bump_x2 = max(_bump_x2, _bx + COLLIDER_REGION_SIZE)
											_bump_y2 = max(_bump_y2, _by + COLLIDER_REGION_SIZE)
											
											angle = force_type_fallback(_thing_info[$ "angle"], "number", 0)
											tag = force_type_fallback(_thing_info[$ "tag"], "number", 0)
											special = _special
											persistent = force_type_fallback(_thing_info[$ "persistent"], "bool", false)
											disposable = force_type_fallback(_thing_info[$ "disposable"], "bool", false)
											array_push(_things, _area_thing)
										} else {
											print($"! proControl: Unknown Thing '{_type_name}' in area {_id}")
											
											delete _area_thing
										}
									}
									
									++_thing_slot
								}
								
								++i
							}
						}
						
						with _area {
							var n = array_length(_things)
							
							if n {
								/* The size of the bump grid is based on the leftmost and rightmost
									area thing positions. Any Things outside of this grid will have
									their region clamped accordingly. */
								ds_grid_resize(
									bump_grid,
									ceil(abs(_bump_x2 - _bump_x1) * COLLIDER_REGION_SIZE_INVERSE),
									ceil(abs(_bump_y2 - _bump_y1) * COLLIDER_REGION_SIZE_INVERSE)
								)
								
								var i = 0
								
								repeat ds_grid_width(bump_grid) {
									var j = 0
									
									repeat ds_grid_height(bump_grid) {
										bump_grid[# i, j++] = ds_list_create()
									}
									
									++i
								}
								
								bump_x = _bump_x1
								bump_y = _bump_y1
							} else {
								// This level has no Things, set defaults
								bump_grid[# 0, 0] = ds_list_create()
							}
						}
						
						// Check for SFX
						var _sfx = _area_info[$ "sfx"]
						
						if is_array(_sfx) {
							var _dsps = _area.dsps
							var _channel = _area.sounds.channel_group
							var i = 0
							
							repeat array_length(_sfx) {
								var _dsp = force_type(_sfx[i++], "struct")
								var _dref = undefined
								
								switch force_type(_dsp[$ "type"], "string") {
									case "echo": {
										_dref = fmod_system_create_dsp_by_type(FMOD_DSP_TYPE.ECHO)
										fmod_dsp_set_parameter_float(_dref, FMOD_DSP_ECHO.DELAY, force_type_fallback(_dsp[$ "delay"], "number", 500))
										fmod_dsp_set_parameter_float(_dref, FMOD_DSP_ECHO.FEEDBACK, force_type_fallback(_dsp[$ "feedback"], "number", 50))
										fmod_dsp_set_parameter_float(_dref, FMOD_DSP_ECHO.WETLEVEL, force_type_fallback(_dsp[$ "wet"], "number", 0))
										fmod_dsp_set_parameter_float(_dref, FMOD_DSP_ECHO.DRYLEVEL, force_type_fallback(_dsp[$ "dry"], "number", 0))
										
										break
									}
									
									case "reverb": {
										_dref = fmod_system_create_dsp_by_type(FMOD_DSP_TYPE.SFXREVERB)
										fmod_dsp_set_parameter_float(_dref, FMOD_DSP_SFXREVERB.DECAYTIME, force_type_fallback(_dsp[$ "decay"], "number", 1500))
										fmod_dsp_set_parameter_float(_dref, FMOD_DSP_SFXREVERB.EARLYDELAY, force_type_fallback(_dsp[$ "early_delay"], "number", 20))
										fmod_dsp_set_parameter_float(_dref, FMOD_DSP_SFXREVERB.LATEDELAY, force_type_fallback(_dsp[$ "late_delay"], "number", 40))
										fmod_dsp_set_parameter_float(_dref, FMOD_DSP_SFXREVERB.HFREFERENCE, force_type_fallback(_dsp[$ "hf_reference"], "number", 5000))
										fmod_dsp_set_parameter_float(_dref, FMOD_DSP_SFXREVERB.HFDECAYRATIO, force_type_fallback(_dsp[$ "hf_decay_ratio"], "number", 50))
										fmod_dsp_set_parameter_float(_dref, FMOD_DSP_SFXREVERB.DIFFUSION, force_type_fallback(_dsp[$ "diffusion"], "number", 50))
										fmod_dsp_set_parameter_float(_dref, FMOD_DSP_SFXREVERB.DENSITY, force_type_fallback(_dsp[$ "density"], "number", 50))
										fmod_dsp_set_parameter_float(_dref, FMOD_DSP_SFXREVERB.LOWSHELFFREQUENCY, force_type_fallback(_dsp[$ "low_shelf_frequency"], "number", 250))
										fmod_dsp_set_parameter_float(_dref, FMOD_DSP_SFXREVERB.LOWSHELFGAIN, force_type_fallback(_dsp[$ "low_shelf_gain"], "number", 0))
										fmod_dsp_set_parameter_float(_dref, FMOD_DSP_SFXREVERB.HIGHCUT, force_type_fallback(_dsp[$ "high_cut"], "number", 20000))
										fmod_dsp_set_parameter_float(_dref, FMOD_DSP_SFXREVERB.EARLYLATEMIX, force_type_fallback(_dsp[$ "early_late_mix"], "number", 50))
										fmod_dsp_set_parameter_float(_dref, FMOD_DSP_SFXREVERB.WETLEVEL, force_type_fallback(_dsp[$ "wet"], "number", -6))
										fmod_dsp_set_parameter_float(_dref, FMOD_DSP_SFXREVERB.DRYLEVEL, force_type_fallback(_dsp[$ "dry"], "number", 0))
										
										break
									}
								}
								
								if _dref != undefined {
									fmod_channel_control_add_dsp(_channel, FMOD_CHANNELCONTROL_DSP_INDEX.TAIL, _dref)
									ds_list_add(_dsps, _dref)
								}
							}
						}
					} else {
						show_error($"!!! proControl: Invalid area ID '{_id}', expected real", true)
					}
					
					delete _area_info
				}
			}
#endregion
			
			delete _json
		}
		
		ui_load("Pause")
		
		with proTransition {
			transition_load(transition_script != undefined ? transition_script.name : object_index)
		}
		
		HANDLER_FOREACH_START
			if level_loading != undefined {
				catspeak_execute(level_loading, _level)
			}
		HANDLER_FOREACH_END
		
		_images.end_batch()
		
		var _mdlShadow = global.models.get("mdlShadow")
		
		global.shadow_vbo = _mdlShadow != undefined ? _mdlShadow.submodels[0].vbo : undefined
		load_state = LoadStates.FINISH
		
		exit
	}
		
	case LoadStates.FINISH: {
		global.transition_canvas.Flush()
		game_update_status()
		global.tick_scale = 1
		
		var _level = global.level
		
		with proTransition {
			if state == 2 {
				state = 3
				
				if reload != undefined {
					reload()
				}
			}
		}
		
		load_state = LoadStates.NONE
		
		var i = 0
		
		with _level {
			repeat array_length(music) {
				var _track = music[i]
				var _asset
				
				if is_string(_track) {
					_asset = global.music.fetch(_track)
					music_play(_asset, i)
				} else if is_struct(_track) {
					_asset = global.music.fetch(force_type(_track[$ "name"], "string"))
					
					var _priority = force_type_fallback(_track[$ "priority"], "number", i)
					var _loop = force_type_fallback(_track[$ "loop"], "bool", true)
					var _active = force_type_fallback(_track[$ "active"], "bool", true)
					
					music_play(_asset, _priority, _loop, 1, 0, _active)
				}
				
				music[i] = _asset;
				++i
			}
		}
		
		var _players = global.players
		var _load_area = load_area
		var _load_tag = load_tag
		
		i = 0
		
		repeat MAX_PLAYERS {
			with _players[i++] {
				level = _level
				set_state("frozen", false)
				set_state("hud", true)
				set_state("invincible", false)
				
				// Bring new players in-game
				if status == PlayerStatus.PENDING {
					status = PlayerStatus.ACTIVE;
					
					var _players_ready = global.players_ready
					
					ds_list_delete(_players_ready, ds_list_find_index(_players_ready, self))
					ds_list_add(global.players_active, self)
				}
			}
		}
		
		HANDLER_FOREACH_START
			if level_started != undefined {
				catspeak_execute(level_started, _level)
			}
		HANDLER_FOREACH_END
		
		if global.demo_write and global.demo_buffer == undefined {
			var _demo_buffer = buffer_create(1, buffer_grow, 1)
			
			// Header
			buffer_write(_demo_buffer, buffer_string, "PNEDEMO")
			buffer_write(_demo_buffer, buffer_string, GM_version)
			
			/* Add a special integer to check if this was recorded during a
			   netgame. (0 = local, 1 = host, 2 = client)
			   Some mods may have special behaviour on netgames, so this is
			   required. */
			buffer_write(_demo_buffer, buffer_u8, 0)
			
			// Mods
			var _mods = global.mods
			var n = ds_map_size(_mods)
			
			buffer_write(_demo_buffer, buffer_u32, n)
			_key = ds_map_find_first(_mods)
			
			repeat n {
				buffer_write(_demo_buffer, buffer_string, _key)
				buffer_write(_demo_buffer, buffer_string, _mods[? _key].version)
				_key = ds_map_find_next(_mods, _key)
			}
			
			// States
			buffer_write(_demo_buffer, buffer_u8, MAX_PLAYERS)
			i = 0
			
			repeat MAX_PLAYERS {
				buffer_write(_demo_buffer, buffer_u8, i)
				
				with _players[i++] {
					buffer_write(_demo_buffer, buffer_u8, status)
					write_states(_demo_buffer)
				}
			}
			
			// Level & flags
			buffer_write(_demo_buffer, buffer_string, load_level)
			buffer_write(_demo_buffer, buffer_u32, load_area)
			buffer_write(_demo_buffer, buffer_s32, load_tag)
			global.global_flags.write(_demo_buffer)
			global.demo_buffer = _demo_buffer
			print("proControl: Recording demo")
		}
		
		np_setpresence_timestamps(_level.rp_time ? date_current_datetime() : 0, 0, false)
		i = 0
		
		repeat MAX_PLAYERS {
			with _players[i++] {
				if status == PlayerStatus.ACTIVE {
					set_area(_load_area, _load_tag)
				}
			}
		}
		
		exit
	}
}

if global.freeze_step {
	// Don't do any ticking on this frame
	global.freeze_step = false
	
	exit
}

var _console = global.console
var _ui = global.ui
var _config = global.config
var _mouse_focused = mouse_focused

if _mouse_focused {
	if not InputGameHasFocus() or not window_has_focus()
	   or not _config.in_mouse.value
	   or _console or global.debug_overlay
	   or (ui_exists(_ui) and (_ui.f_blocking or _ui.f_block_input)) {
		window_mouse_set_locked(false)
		window_set_cursor(cr_default)
		mouse_focused = false
		_mouse_focused = false
	}
} else if InputGameHasFocus() and window_has_focus()
          and _config.in_mouse.value
          and not _console and not global.debug_overlay
          and not (ui_exists(_ui) and (_ui.f_blocking or _ui.f_block_input)) {
	window_mouse_set_locked(true)
	window_set_cursor(cr_none)
	mouse_dx = 0
	mouse_dy = 0
	mouse_focused = true
	_mouse_focused = true
}

var _tick = global.tick
var _tick_inc = delta_time * TICKRATE_DELTA
var _tick_scale = global.tick_scale

global.delta = _tick_inc
_tick = min(_tick + (_tick_inc * _tick_scale), TICKRATE)
InputManualCollect()

if _mouse_focused {
	mouse_dx += window_mouse_get_delta_x()
	mouse_dy += window_mouse_get_delta_y()
}

var _interps = global.interps

if _tick >= 1 {
	// Cache game session info
	var _demo_write = global.demo_write
	var _demo_buffer = global.demo_buffer
	var _playing_demo = not _demo_write and _demo_buffer != undefined
	var _recording_demo = _demo_write and _demo_buffer != undefined
	var _block_input = false
	
	var _game_tick = _tick
	var _ui_tick = _tick
	var _trans_tick = _tick
	
#region Debug
	if InputPressed(INPUT_VERB.DEBUG_OVERLAY) {
		global.debug_overlay = not global.debug_overlay
		show_debug_overlay(global.debug_overlay)
	}
	
	if InputPressed(INPUT_VERB.DEBUG_FPS) {
		global.debug_fps = not global.debug_fps
	}
	
	if InputPressed(INPUT_VERB.DEBUG_INPUT) {
		global.debug_input = not global.debug_input
	}
	
	if _console {
		InputManualUpdate()
		mouse_dx = 0
		mouse_dy = 0
		InputVerbConsume(INPUT_VERB.LEAVE)
		
		if InputPressed(INPUT_VERB.DEBUG_CONSOLE_PREVIOUS) {
			keyboard_string = global.console_input_previous
		}
		
		if InputPressed(INPUT_VERB.DEBUG_CONSOLE_SUBMIT) {
			var _input = string_trim(keyboard_string)
			
			if _input != "" {
				global.console_input_previous = _input
				print($"> {_input}")
				
				array_foreach(string_split(_input, ";", true), function (_element, _index) {
					var _input = string_trim(_element)
				
					if _input != "" {
						var _cmd = _input
						var _args = ""
						var _args_pos = string_pos(" ", _cmd)
						
						if _args_pos > 0 {
							_cmd = string_copy(_cmd, 1, _args_pos - 1)
							_args = string_delete(_input, 1, _args_pos)
						}
						
						var _cmd_function = variable_global_get($"cmd_{_cmd}")
						
						if is_method(_cmd_function) {
							_cmd_function(_args)
						} else {
							print($"Unknown command '{_cmd}'")
						}
					}
				})
			}
			
			keyboard_string = ""
			
			if global.demo_buffer == undefined {
				_playing_demo = false
				_recording_demo = false
			}
		} else if InputPressed(INPUT_VERB.PAUSE) {
			global.console_input = keyboard_string
			cmd_close("")
			InputVerbConsume(INPUT_VERB.PAUSE)
		}
		
		_game_tick = 0
		_ui_tick = 0
		_trans_tick = 0
	} else if InputPressed(INPUT_VERB.DEBUG_CONSOLE) {
		InputSetHotswap(false)
		global.console = true
		keyboard_string = global.console_input
		fmod_channel_control_set_paused(global.world_channel_group, true)
		_block_input = true
	} else if _playing_demo {
		var _demo_target = MAX_PLAYERS
		
		if InputPressed(INPUT_VERB.DEBUG_CAMERA1) _demo_target = 0
		else if InputPressed(INPUT_VERB.DEBUG_CAMERA2) _demo_target = 1
		else if InputPressed(INPUT_VERB.DEBUG_CAMERA3) _demo_target = 2
		else if InputPressed(INPUT_VERB.DEBUG_CAMERA4) _demo_target = 3
		
		if _demo_target < MAX_PLAYERS {
			with global.players[_demo_target] {
				if status != PlayerStatus.ACTIVE or area == undefined or not thing_exists(thing) {
					global.camera_demo = noone
					
					break
				}
				
				global.camera_demo = area.nearest(thing.x, thing.y, thing.z, DemoCamera)
			}
		}
		
		if InputPressed(INPUT_VERB.DEBUG_CAMERA_OFF) {
			global.camera_demo = noone
		}
	}
#endregion
	
#region Start Interpolation
	var i = ds_list_size(_interps)
	
	while i {
		var _scope = _interps[| --i]
		
		if _scope == undefined {
			continue
		}
		
		var _ref
		
		if is_numeric(_scope) {
			if instance_exists(_scope) {
				_ref = _scope
			} else {
				_interps[| i] = undefined
				
				continue
			}
		} else if weak_ref_alive(_scope) {
			_ref = _scope.ref
		} else {
			_interps[| i] = undefined
			
			continue
		}
		
		with _ref {
			var j = 0
			
			repeat array_length(__interp) {
				var _element = __interp[j++]
				
				_element[InterpData.PREVIOUS_VALUE] = struct_get_from_hash(self, _element[InterpData.IN_HASH])
			}
		}
	}
#endregion
	
#region Tick Loop
	var _tick_buffer = global.tick_buffer
	var _tick_size = 0
	
	// Cache player stuff
	var _players = global.players
	var _players_active = global.players_active
	var _level = global.level
	
	// Handle player activations by injecting into the tick buffer
	if not _playing_demo and InputPartyGetJoin() {
		i = 0
		
		repeat MAX_PLAYERS {
			var _status = InputPlayerGetStatus(i)
			
			if (_status == INPUT_PLAYER_STATUS.NEWLY_CONNECTED or _status == INPUT_PLAYER_STATUS.CONNECTED) {
				with _players[i] {
					if not input_active {
						inject_tick_packet()
						buffer_write(_tick_buffer, buffer_u8, TickPackets.ACTIVATE)
						buffer_write(_tick_buffer, buffer_u8, i)
						input_active = true
					}
				}
			} else if (_status == INPUT_PLAYER_STATUS.NEWLY_DISCONNECTED or _status == INPUT_PLAYER_STATUS.DISCONNECTED) {
				with _players[i] {
					if input_active {
						inject_tick_packet()
						buffer_write(_tick_buffer, buffer_u8, TickPackets.DEACTIVATE)
						buffer_write(_tick_buffer, buffer_u8, i)
						input_active = false
					}
				}
			}
			
			++i
		}
	}
	
	// Transition (non-deterministic)
	if instance_exists(proTransition) {
		var _skip_tick = false
		
		while _trans_tick >= 1 {
			with proTransition {
				event_tick()
				
				// Freeze the world while the screen is fading in
				switch state {
					case 1:
						var _transition_canvas = global.transition_canvas
						var _width = window_get_width()
						var _height = window_get_height()
						
						_transition_canvas.Resize(_width, _height)
						_transition_canvas.Start()
						draw_clear(c_black)
						event_draw_screen(_width, _height)
						_transition_canvas.Finish()
						
						with proControl {
							load_level = other.to_level
							load_area = other.to_area
							load_tag = other.to_tag
							load_state = LoadStates.START
						}
						
						state = 2
						
					case 0:
					case 2:
						_skip_tick = true
						
						break
				}
			}
			
			--_trans_tick
		}
		
		if _skip_tick {
			InputManualUpdate()
			mouse_dx = 0
			mouse_dy = 0
			_ui_tick = 0
			_game_tick = 0
		}
	}
	
	// UI (non-deterministic)
	if _ui_tick >= 1 {
		var _skip_tick = false
		var _skip_input = false
		
		while _ui_tick >= 1 {
			if _ui != undefined {
				var _ui_input = global.ui_input
				
				if _block_input {
					_ui_input[UIInputs.UP_DOWN] = 0
					_ui_input[UIInputs.LEFT_RIGHT] = 0
					_ui_input[UIInputs.CONFIRM] = false
					_ui_input[UIInputs.BACK] = false
					_ui_input[UIInputs.MOUSE_CONFIRM] = false
				} else {
					_ui_input[UIInputs.UP_DOWN] = InputOpposingRepeat(INPUT_VERB.UI_UP, INPUT_VERB.UI_DOWN)
					_ui_input[UIInputs.LEFT_RIGHT] = InputOpposingRepeat(INPUT_VERB.UI_LEFT, INPUT_VERB.UI_RIGHT)
					_ui_input[UIInputs.CONFIRM] = InputPressed(INPUT_VERB.UI_ENTER)
					_ui_input[UIInputs.BACK] = InputPressed(INPUT_VERB.PAUSE)
					
					if _mouse_focused {
						_ui_input[UIInputs.MOUSE_X] = InputMouseGuiX()
						_ui_input[UIInputs.MOUSE_Y] = InputMouseGuiY()
						_ui_input[UIInputs.MOUSE_CONFIRM] = InputPressed(INPUT_VERB.UI_CLICK)
					} else {
						_ui_input[UIInputs.MOUSE_CONFIRM] = false
					}
				}
				
				var _tick_target = _ui
				
				while true {
					var _child = _tick_target.child
					
					if _child == undefined {
						break
					}
					
					_tick_target = _child
				}
				
				with _tick_target {
					if tick != undefined {
						catspeak_execute(tick)
					}
					
					if not exists and parent != undefined {
						_tick_target = parent
					}
				}
				
				if _tick_target.exists {
					if _tick_target.f_blocking {
						_skip_tick = true
					} else if _tick_target.f_block_input {
						_skip_input = true
					}
				}
			} else {
				var _paused = false
				
				if not _block_input and InputPressed(INPUT_VERB.PAUSE) {
					_paused = true
					i = ds_list_size(_players_active)
					
					while i {
						with _players_active[| --i] {
							if status != PlayerStatus.ACTIVE {
								break
							}
							
							if not thing_exists(thing) or get_state("frozen") {
								_paused = false
								
								break
							}
						}
						
						if not _paused {
							break
						}
					}
				}
				
				if _paused {
					var _pause = ui_create("Pause", {level: _level})
					
					if ui_exists(_pause) and _pause.f_blocking {
						_skip_tick = true
					}
				}
			}
			
			// Try to clear momentary input if game ticks are skipped
			if _skip_tick {
				InputManualUpdate()
				mouse_dx = 0
				mouse_dy = 0
			}
			
			--_ui_tick
		}
		
		if _skip_input {
			_block_input = true
		}
		
		if _skip_tick {
			if (global.game_status & GameStatus.NETGAME) {
				_block_input = true
			} else {
				_game_tick = 0
			}
		}
	}
	
	var _camera_man = global.camera_man
	var _has_camera_man = thing_exists(_camera_man)
	var _camera_man_freeze = global.camera_man_freeze
	
	COLLECT_DESTROYED_START
	
	while _game_tick >= 1 {
#region Cameraman (non-deterministic)
		if _has_camera_man and _camera_man_freeze {
			var _dyaw = 0
			var _dpitch = 0
			var _droll = 0
			
			with _config {
				_dyaw += (InputValue(INPUT_VERB.AIM_RIGHT) - InputValue(INPUT_VERB.AIM_LEFT)) * in_aim_x.value
				_dpitch += (InputValue(INPUT_VERB.AIM_DOWN) - InputValue(INPUT_VERB.AIM_UP)) * in_aim_y.value
				
				if _mouse_focused {
					_dyaw += other.mouse_dx * in_mouse_x.value
					_dpitch += other.mouse_dy * in_mouse_y.value
				}
				
				if in_gyro.value {
					var _gyro = InputMotionGet()
					
					if _gyro != undefined {
						_dyaw += radtodeg(_gyro.angularVelocityY) * in_gyro_y.value
						_dpitch -= radtodeg(_gyro.angularVelocityX) * in_gyro_x.value
					}
				}
			}
			
			with _camera_man {
				if InputPressed(INPUT_VERB.INTERACT) {
					roll = 0
					fov = 45
				}
				
				if InputCheck(INPUT_VERB.AIM) {
					roll += _dyaw
					fov += _dpitch
				} else {
					yaw += _dyaw
					pitch += _dpitch
				}
				
				var _speed = power(2, (not InputCheck(INPUT_VERB.WALK)) + InputCheck(INPUT_VERB.ATTACK))
				var _forward = (InputValue(INPUT_VERB.UP) - InputValue(INPUT_VERB.DOWN)) * _speed
				var _side = (InputValue(INPUT_VERB.LEFT) - InputValue(INPUT_VERB.RIGHT)) * _speed
				
				_forward = lengthdir_3d(_forward, yaw, pitch)
				
				var _dx = _forward[0]
				var _dy = _forward[1]
				var _dz = _forward[2]
				
				_side = lengthdir_3d(_side, yaw - 90, -roll)
				_dx += _side[0]
				_dy += _side[1]
				_dz += _side[2]
				
				set_position(x + _dx, y + _dy, z + _dz)
			}
			
			InputManualUpdate()
			mouse_dx = 0
			mouse_dy = 0;
			--_game_tick
			
			continue
		}
#endregion
		
		// Write to tick buffer
		if global.inject_tick_buffer {
			global.inject_tick_buffer = false
		} else {
			buffer_seek(_tick_buffer, buffer_seek_start, 0)
		}
		
		if _playing_demo {
			_tick_size = buffer_read(_demo_buffer, buffer_u32)
			
			if _tick_size == 0xFFFFFFFF {
				cmd_dend("")
				_demo_buffer = undefined
				_playing_demo = false
				_game_tick = 0
				
				break
			}
			
			var _pos = buffer_tell(_demo_buffer)
			
			buffer_copy(_demo_buffer, _pos, _tick_size, _tick_buffer, 0)
			buffer_seek(_demo_buffer, buffer_seek_relative, _tick_size)
			buffer_resize(_tick_buffer, _tick_size)
		} else {
			// Local input
			var _mouse_dx = mouse_dx
			var _mouse_dy = mouse_dy
			
			i = 0
			
			repeat ds_list_size(_players_active) {
				with _players_active[| i++] {
					var j = slot
					var _input_up_down, _input_left_right, _input_flags, _dx, _dy
					
					if _block_input {
						_input_up_down = 0
						_input_left_right = 0
						_input_flags = 0
						_dx = 0
						_dy = 0
					} else {
						// Main
						var _move_range = InputCheck(INPUT_VERB.WALK, j) ? 64 : 127
						
						_input_up_down = floor((InputValue(INPUT_VERB.DOWN, j) - InputValue(INPUT_VERB.UP, j)) * _move_range)
						_input_left_right = floor((InputValue(INPUT_VERB.RIGHT, j) - InputValue(INPUT_VERB.LEFT, j)) * _move_range)
						
						_input_flags = player_input_to_flags(
							InputCheck(INPUT_VERB.JUMP, j),
							InputCheck(INPUT_VERB.INTERACT, j),
							InputCheck(INPUT_VERB.ATTACK, j),
							InputCheck(INPUT_VERB.INVENTORY1, j),
							InputCheck(INPUT_VERB.INVENTORY2, j),
							InputCheck(INPUT_VERB.INVENTORY3, j),
							InputCheck(INPUT_VERB.INVENTORY4, j),
							InputCheck(INPUT_VERB.AIM, j)
						)
						
						// Camera
						var _dx_factor = 0
						var _dy_factor = 0
						
						with _config {
							_dx_factor += (InputValue(INPUT_VERB.AIM_RIGHT, j) - InputValue(INPUT_VERB.AIM_LEFT, j)) * in_aim_x.value
							_dy_factor += (InputValue(INPUT_VERB.AIM_DOWN, j) - InputValue(INPUT_VERB.AIM_UP, j)) * in_aim_y.value
							
							if _mouse_focused and InputPlayerUsingKbm(j) {
								_dx_factor += _mouse_dx * in_mouse_x.value
								_dy_factor += _mouse_dy * in_mouse_y.value
							}
							
							if in_gyro.value {
								var _gyro = InputMotionGet(j)
								
								if _gyro != undefined {
									_dx_factor += radtodeg(_gyro.angularVelocityY) * in_gyro_y.value
									_dy_factor -= radtodeg(_gyro.angularVelocityX) * in_gyro_x.value
								}
							}
						}
						
						_dx = floor((abs(_dx_factor) * 0.0027777777777778) * 32768) * sign(_dx_factor)
						_dy = floor((abs(_dy_factor) * 0.0027777777777778) * 32768) * sign(_dy_factor)
					}
					
					buffer_write(_tick_buffer, buffer_u8, TickPackets.INPUT)
					buffer_write(_tick_buffer, buffer_u8, j)
					buffer_write(_tick_buffer, buffer_s8, _input_up_down)
					buffer_write(_tick_buffer, buffer_s8, _input_left_right)
					buffer_write(_tick_buffer, buffer_u8, _input_flags)
					buffer_write(_tick_buffer, buffer_s16, _dx % 32768)
					buffer_write(_tick_buffer, buffer_s16, _dy % 32768)
				}
			}
			
			if _recording_demo {
				with _level {
					if (time % 15) == 0 {
						var _checksum = 0
						
						with Thing {
							if not f_desync {
								_checksum += 1 + floor(x) + floor(y) + floor(z)
							}
						}
						
						buffer_write(_tick_buffer, buffer_u8, TickPackets.CHECKSUM)
						buffer_write(_tick_buffer, buffer_u8, abs(time + _checksum) % 256)
					}
				}
			}
			
			_tick_size = buffer_tell(_tick_buffer)
		}
		
		// Parse tick buffer
		if _recording_demo {
			buffer_write(_demo_buffer, buffer_u32, _tick_size)
			
			var _pos = buffer_tell(_demo_buffer)
			
			buffer_copy(_tick_buffer, 0, _tick_size, _demo_buffer, _pos)
			buffer_seek(_demo_buffer, buffer_seek_relative, _tick_size)
		}
		
		buffer_seek(_tick_buffer, buffer_seek_start, 0)
		
		while buffer_tell(_tick_buffer) < _tick_size {
			switch buffer_read(_tick_buffer, buffer_u8) {
				case TickPackets.ACTIVATE: {
					var _slot = buffer_read(_tick_buffer, buffer_u8)
					
					with _players[_slot] {
						if not player_activate(self) {
							show_caption($"[c_lime]{lexicon_text("hud.caption.player.reconnect", -~_slot)} ({string_device(_slot)})")
						}
					}
					
					break
				}
				
				case TickPackets.DEACTIVATE: {
					var _slot = buffer_read(_tick_buffer, buffer_u8)
					
					if not player_deactivate(_players[_slot]) {
						show_caption($"[c_red]{lexicon_text("hud.caption.player.last_disconnect", -~_slot, string_input(INPUT_VERB.JUMP, _slot))}")
					}
					
					break
				}
				
				case TickPackets.INPUT: {
					var _slot = buffer_read(_tick_buffer, buffer_u8)
					
					with _players[_slot] {
						array_copy(input_previous, 0, input, 0, PlayerInputs.__SIZE)
						input[PlayerInputs.UP_DOWN] = buffer_read(_tick_buffer, buffer_s8)
						input[PlayerInputs.LEFT_RIGHT] = buffer_read(_tick_buffer, buffer_s8)
						
						var _input_flags = buffer_read(_tick_buffer, buffer_u8)
						
						input[PlayerInputs.JUMP] = (_input_flags & PIFlags.JUMP) != 0
						input[PlayerInputs.INTERACT] = (_input_flags & PIFlags.INTERACT) != 0
						input[PlayerInputs.ATTACK] = (_input_flags & PIFlags.ATTACK) != 0
						input[PlayerInputs.INVENTORY1] = (_input_flags & PIFlags.INVENTORY1) != 0
						input[PlayerInputs.INVENTORY2] = (_input_flags & PIFlags.INVENTORY2) != 0
						input[PlayerInputs.INVENTORY3] = (_input_flags & PIFlags.INVENTORY3) != 0
						input[PlayerInputs.INVENTORY4] = (_input_flags & PIFlags.INVENTORY4) != 0
						input[PlayerInputs.AIM] = (_input_flags & PIFlags.AIM) != 0
						input[PlayerInputs.AIM_LEFT_RIGHT] = buffer_read(_tick_buffer, buffer_s16)
						input[PlayerInputs.AIM_UP_DOWN] = buffer_read(_tick_buffer, buffer_s16)
					}
					
					break
				}
				
				case TickPackets.LEVEL: {
					var _name = buffer_read(_tick_buffer, buffer_string)
					var _area = buffer_read(_tick_buffer, buffer_u32)
					var _tag = buffer_read(_tick_buffer, buffer_s32)
					
					if _level != undefined {
						_level.goto(_name, _area, _tag)
					}
					
					_game_tick = 0
					
					break
				}
				
				case TickPackets.CHECKSUM: {
					var _checksum = buffer_read(_tick_buffer, buffer_u8)
					
					if _playing_demo {
						var _clientsum = 0
						
						with Thing {
							if not f_desync {
								_clientsum += 1 + floor(x) + floor(y) + floor(z)
							}
						}
						
						_clientsum = abs(_level.time + _clientsum) % 256
						
						if _checksum != _clientsum {
							show_caption($"[c_red]Desync! ({_clientsum} =/= {_checksum})", infinity)
						}
					}
					
					break
				}
				
				case TickPackets.SIGNAL: {
					var _slot = buffer_read(_tick_buffer, buffer_u8)
					var _sender = _slot < MAX_PLAYERS ? _players[_slot] : undefined
					var _name = buffer_read(_tick_buffer, buffer_string)
					var _argc = buffer_read(_tick_buffer, buffer_u8)
					var _args = global.signal_args
					
					array_resize(_args, _argc)
					i = 0
					
					repeat _argc {
						_args[i++] = buffer_read_dynamic(_tick_buffer)
					}
					
					HANDLER_FOREACH_START
						if ui_signalled != undefined {
							catspeak_execute(ui_signalled, _sender, _name, _args)
						}
					HANDLER_FOREACH_END
				}
			}
		}
		
#region Game Loop
		i = ds_list_size(_players_active)
		
		while i {
			with _players_active[| --i] {
#region Area
				if area != undefined {
					with area {
						if master != other {
							break
						}
						
						var _players_in_area = players
						
						// Thing pre-processing
						var j = ds_list_size(active_things)
						
						while j {
							with active_things[| --j] {
								x_previous = x
								y_previous = y
								z_previous = z
								angle_previous = angle
							}
						}
						
						// Tick Things with Colliders first so that other
						// Things that stick to them don't lag behind.
						j = ds_list_size(tick_colliders)
						
						while j {
							with tick_colliders[| --j] {
								var _can_tick = true
								
								if cull_tick != infinity {
									_can_tick = false
									
									var _ox = x
									var _oy = y
									var _od = cull_tick
									var k = ds_list_size(_players_in_area)
									
									while k {
										with _players_in_area[| --k] {
											if thing_exists(thing) and point_distance(thing.x, thing.y, _ox, _oy) < _od {
												_can_tick = true
											}
										}
										
										if _can_tick {
											break
										}
									}
								}
								
								if _can_tick {
									f_culled = false
									
									if not f_frozen {
										event_tick()
									}
								} else {
									f_culled = true
									
									if f_cull_destroy {
										destroy(false)
									}
								}
							}
						}
						
						j = ds_list_size(tick_things)
						
						while j {
							with tick_things[| --j] {
								var _can_tick = true
								
								if cull_tick != infinity {
									_can_tick = false
									
									var _ox = x
									var _oy = y
									var _od = cull_tick
									var k = ds_list_size(_players_in_area)
									
									while k {
										with _players_in_area[| --k] {
											if thing_exists(thing) and point_distance(thing.x, thing.y, _ox, _oy) < _od {
												_can_tick = true
											}
										}
										
										if _can_tick {
											break
										}
									}
								}
								
								if _can_tick {
									f_culled = false
									
									if not f_frozen {
										event_tick()
									}
								} else {
									f_culled = true
									
									if f_cull_destroy {
										destroy(false)
									}
								}
							}
						}
					}
				}
#endregion
			}
		}
		
		COLLECT_DESTROYED_END
		
		// Assume that "_level" is never undefined.
		++_level.time
#endregion
		
		InputManualUpdate()
		mouse_dx = 0
		mouse_dy = 0;
		--_game_tick
	}
#endregion
	
	_tick -= floor(_tick)
}

global.tick = _tick

#region End Interpolation
var i = ds_list_size(_interps)

if _config.vid_max_fps.value <= (TICKRATE * _tick_scale) {
#region Interpolation OFF (FPS <= TICKRATE)
	while i {
		var _scope = _interps[| --i]
		
		if _scope == undefined {
			continue
		}
		
		var _ref
		
		if is_numeric(_scope) {
			if instance_exists(_scope) {
				_ref = _scope
			} else {
				_interps[| i] = undefined
				
				continue
			}
		} else if weak_ref_alive(_scope) {
			_ref = _scope.ref
		} else {
			_interps[| i] = undefined
			
			continue
		}
		
		with _ref {
			var j = 0
			
			repeat array_length(__interp) {
				var _element = __interp[j++]
				
				struct_set_from_hash(self, _element[InterpData.OUT_HASH], struct_get_from_hash(self, _element[InterpData.IN_HASH]))
			}
		}
	}
#endregion
} else {
#region Interpolation ON (FPS > TICKRATE)
	while i {
		var _scope = _interps[| --i]
		
		if _scope == undefined {
			continue
		}
		
		var _ref
		
		if is_numeric(_scope) {
			if instance_exists(_scope) {
				_ref = _scope
			} else {
				_interps[| i] = undefined
				
				continue
			}
		} else if weak_ref_alive(_scope) {
			_ref = _scope.ref
		} else {
			_interps[| i] = undefined
			
			continue
		}
		
		with _ref {
			var j = 0
			
			repeat array_length(__interp) {
				var _child = __interp[j++]
				
				struct_set_from_hash(_ref, _child[InterpData.OUT_HASH], (_child[InterpData.ANGLE] ? lerp_angle : lerp)(_child[InterpData.PREVIOUS_VALUE], struct_get_from_hash(_ref, _child[InterpData.IN_HASH]), _tick)) // This line is already long enough, but why not make it even longer with this useless comment?
			}
		}
	}
#endregion
}
#endregion