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
		
		global.level.destroy()
		
		var _players = global.players
		
		i = 0
		
		repeat INPUT_MAX_PLAYERS {
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
		//global.fonts.clear()
		global.sounds.clear()
		global.music.clear()
		
		if load_level == undefined {
			game_end()
			
			exit
		}
		
		global.flags[FlagGroups.LOCAL].clear()
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
			if not force_type_fallback(_json[$ "allow_demos"], "bool", true) {
				if global.demo_write {
					if global.demo_buffer != undefined {
						var _filename = "demo_" + string_replace_all(date_datetime_string(date_current_datetime()), "/", ".")
						
						cmd_dend(_filename)
						show_caption($"[c_red]Recording ended on a protected level.\nSaved as '{_filename}.pnd'.")
					} else {
						cmd_dend("")
						show_caption("[c_red]Recording cancelled by a protected level.")
					}
				} else {
					if global.demo_buffer != undefined {
						cmd_dend("")
						show_caption("[c_red]Demo ended on a protected level.")
					}
				}
			}
			
			with global.rng_game {
				left = DEFAULT_RNG_LEFT
				right = DEFAULT_RNG_RIGHT
			}
			
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
			
			var _script = _json[$ "script"]
			
			if is_string(_script) {
				with _level {
					level_script = global.scripts.fetch(_script)
					
					if level_script != undefined {
						start = level_script.start
						area_changed = level_script.area_changed
						area_activated = level_script.area_activated
						area_deactivated = level_script.area_deactivated
					}
				}
			}
			
			var _music_tracks = _json[$ "music"]
			
			if _music_tracks != undefined {
				var _music = global.music
				
				if is_string(_music_tracks) {
					_level.music = [_music_tracks]
				} else {
					if is_array(_music_tracks) {
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
				var _flags = global.flags
				var _copy_global = force_type_fallback(_copy_flags[$ "global"], "struct")
				
				if _copy_global != undefined {
					_flags[FlagGroups.GLOBAL].copy(_copy_global)
				}
				
				var _copy_local = force_type_fallback(_copy_flags[$ "local"], "struct")
				
				if _copy_local != undefined {
					_flags[FlagGroups.LOCAL].copy(_copy_local)
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
							_images.load("imgShadow")
							
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
								var _width = ceil(abs(_bump_x2 - _bump_x1) * COLLIDER_REGION_SIZE_INVERSE)
								var _height = ceil(abs(_bump_y2 - _bump_y1) * COLLIDER_REGION_SIZE_INVERSE)
								
								ds_grid_resize(bump_grid, _width, _height)
								ds_grid_resize(bump_lists, _width, _height)
								
								var i = 0
								
								repeat ds_grid_width(bump_lists) {
									var j = 0
									
									repeat ds_grid_height(bump_lists) {
										bump_lists[# i, j++] = ds_list_create()
									}
									
									++i
								}
								
								bump_x = _bump_x1
								bump_y = _bump_y1
							} else {
								// This level has no Things, set defaults
								bump_lists[# 0, 0] = ds_list_create()
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
		
		_images.end_batch()
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
				} else {
					if is_struct(_track) {
						_asset = global.music.fetch(force_type(_track[$ "name"], "string"))
						
						var _priority = force_type_fallback(_track[$ "priority"], "number", i)
						var _loop = force_type_fallback(_track[$ "loop"], "bool", true)
						var _active = force_type_fallback(_track[$ "active"], "bool", true)
						
						music_play(_asset, _priority, _loop, 1, 0, _active)
					}
				}
				
				music[i] = _asset;
				++i
			}
		}
		
		var _players = global.players
		var _load_area = load_area
		var _load_tag = load_tag
		
		i = 0
		
		repeat INPUT_MAX_PLAYERS {
			with _players[i++] {
				level = _level
				set_state("frozen", false)
				set_state("hud", true)
				set_state("invincible", false)
				
				// Bring new players in-game
				if status == PlayerStatus.PENDING {
					status = PlayerStatus.ACTIVE;
					++global.players_active;
					--global.players_ready
				}
			}
		}
		
		if global.demo_write and global.demo_buffer == undefined {
			var _demo_buffer = buffer_create(1, buffer_grow, 1)
			
			// Header
			buffer_write(_demo_buffer, buffer_string, "PNEDEMO")
			buffer_write(_demo_buffer, buffer_string, GM_version)
			
			/* Add a special boolean to check if this was recorded during a
			   netgame.
			   Some mods may have special behaviour on netgames, so this is
			   required. */
			buffer_write(_demo_buffer, buffer_bool, global.game_status & GameStatus.NETGAME)
			
			// Mods
			var _mods = global.mods
			var n = ds_map_size(_mods)
			
			buffer_write(_demo_buffer, buffer_u32, n)
			
			var _key = ds_map_find_first(_mods)
			
			repeat n {
				buffer_write(_demo_buffer, buffer_string, _key)
				buffer_write(_demo_buffer, buffer_string, _mods[? _key].version)
				_key = ds_map_find_next(_mods, _key)
			}
			
			// States
			buffer_write(_demo_buffer, buffer_u8, INPUT_MAX_PLAYERS)
			i = 0
			
			repeat INPUT_MAX_PLAYERS {
				buffer_write(_demo_buffer, buffer_u8, i)
				
				with _players[i++] {
					buffer_write(_demo_buffer, buffer_u8, status)
					write_states(_demo_buffer)
				}
			}
			
			// Level
			buffer_write(_demo_buffer, buffer_string, load_level)
			buffer_write(_demo_buffer, buffer_u32, load_area)
			buffer_write(_demo_buffer, buffer_s32, load_tag)
			
			// Flags
			global.flags[FlagGroups.GLOBAL].write(_demo_buffer)
			
			global.demo_buffer = _demo_buffer
			global.demo_time = 0
			global.demo_next = 0
			print("proControl: Recording demo")
		}
		
		with _level {
			if start != undefined {
				catspeak_execute(start)
			}
			
			np_setpresence_timestamps(rp_time ? date_current_datetime() : 0, 0, false)
		}
		
		i = 0
		
		repeat INPUT_MAX_PLAYERS {
			with _players[i++] {
				if status == PlayerStatus.ACTIVE {
					set_area(_load_area, _load_tag)
				}
			}
		}
		
		var _netgame = global.netgame
		
		if _netgame != undefined and _netgame.active {
			if _netgame.master {
				load_state = LoadStates.HOST_READY
			} else {
				_netgame.send_host(net_buffer_create(true, NetHeaders.CLIENT_LEVEL_READY))
				load_state = LoadStates.CLIENT_READY
			}
		}
		
		exit
	}
	
	case LoadStates.CONNECT: {
		// This is a dummy load state that waits until the netgame connection
		// returns a result.
		exit
	}
	
	case LoadStates.CLIENT_WAIT: {
		/* This is a dummy load state that waits until an actual level
		   transition happens from the host.
		   If you get softlocked here, too bad! */
		
		if not global.netgame.load_queue {
			exit
		}
	}
	
	case LoadStates.HOST_READY: {
		// Wait until clients have finished loading.
		var _ready = true
		var _netgame = global.netgame
		
		with _netgame {
			var i = 0
			
			repeat ds_list_size(players) {
				var _player = players[| i++]
				
				if _player == undefined {
					continue
				}
				
				if not _player.ready {
					_ready = false
					
					break
				}
			}
		}
		
		if _ready {
			_netgame.send_others(net_buffer_create(true, NetHeaders.HOST_LEVEL_READY))
			load_state = LoadStates.NONE
		}
		
		exit
	}
	
	case LoadStates.CLIENT_READY: {
		// Wait until host has finished loading.
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
var _mouse_focused = global.mouse_focused

if _mouse_focused {
	if not _console and not global.debug_overlay and window_has_focus() and _ui == undefined {
		mouse_dx += window_mouse_get_delta_x()
		mouse_dy += window_mouse_get_delta_y()
	} else {
		window_mouse_set_locked(false)
		global.mouse_focused = false
		_mouse_focused = false
		mouse_dx = 0
		mouse_dy = 0
	}
} else {
	if not _console and not global.debug_overlay and window_has_focus() and _ui == undefined {
		window_mouse_set_locked(true)
		global.mouse_focused = true
		_mouse_focused = true
	}
	
	mouse_dx = 0
	mouse_dy = 0
}

var _tick = global.tick
var _tick_inc = delta_time * TICKRATE_DELTA
var _tick_scale = global.tick_scale

global.delta = _tick_inc
_tick += _tick_inc * _tick_scale

var _interps = global.interps
var _config = global.config

if _tick >= 1 {
	// Cache a lot of things into local variables
	var _players = global.players
	var _level = global.level
	var _demo_write = global.demo_write
	var _demo_buffer = global.demo_buffer
	var _demo_input = global.demo_input
	var _has_demo = _demo_buffer != undefined
	var _playing_demo = not _demo_write and _has_demo
	var _recording_demo = _demo_write and _has_demo
	var _netgame = global.netgame
	var _in_netgame = _netgame != undefined and _netgame.active
	var _is_master = not _in_netgame or _netgame.master
	
	__input_system_tick()
	
#region New Players
	if not _has_demo and not _in_netgame {
		with input_players_get_status() {
			if __any_changed {
				print($"proControl: Player input status updated ({__new_connections}, {__new_disconnections})")
				var i = 0
				
				repeat array_length(__new_connections) {
					with _players[__new_connections[i++]] {
						if not activate() {
							if __show_reconnect_caption {
								var _device = input_player_get_gamepad_type(slot)
								
								if _device == "unknown" {
									_device = "no controller"
								}
								
								show_caption($"[c_lime]{lexicon_text("hud.caption.player.reconnect", -~slot)} ({_device})")
							} else {
								__show_reconnect_caption = true
							}
						}
					}
				}
				
				i = 0
				
				repeat array_length(__new_disconnections) {
					with _players[__new_disconnections[i++]] {
						if not deactivate() {
							show_caption($"[c_red]{lexicon_text("hud.caption.player.last_disconnect", -~slot)}")
						}
					}
				}
			}
		}
	}
#endregion
	
#region Debug
	if input_check_pressed("debug_overlay") {
		global.debug_overlay = not global.debug_overlay
		show_debug_overlay(global.debug_overlay)
	}
	
	if input_check_pressed("debug_fps") {
		global.debug_fps = not global.debug_fps
	}
	
	if _console {
		input_verb_consume("leave")
		
		if input_check_pressed("debug_console_previous") {
			keyboard_string = global.console_input_previous
		}
		
		if input_check_pressed("debug_console_submit") {
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
			
			if global.netgame == undefined {
				_in_netgame = false
				_is_master = true
			}
			
			if global.demo_buffer == undefined {
				_has_demo = false
				_playing_demo = false
				_recording_demo = false
			}
		} else if input_check_pressed("pause") {
			global.console_input = keyboard_string
			cmd_close("")
			input_verb_consume("pause")
		}
		
		if _in_netgame {
			input_verb_consume("up")
			input_verb_consume("left")
			input_verb_consume("down")
			input_verb_consume("right")
			input_verb_consume("walk")
			input_verb_consume("jump")
			input_verb_consume("interact")
			input_verb_consume("attack")
			input_verb_consume("inventory_up")
			input_verb_consume("inventory_left")
			input_verb_consume("inventory_down")
			input_verb_consume("inventory_right")
			input_verb_consume("aim")
			input_verb_consume("aim_up")
			input_verb_consume("aim_left")
			input_verb_consume("aim_down")
			input_verb_consume("aim_right")
		} else {
			_tick = 0
		}
	} else {
		if input_check_pressed("debug_console") {
			input_source_mode_set(INPUT_SOURCE_MODE.FIXED)
			global.console = true
			keyboard_string = global.console_input
			
			if not _in_netgame {
				fmod_channel_control_set_paused(global.world_channel_group, true)
			}
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
		} else {
			if weak_ref_alive(_scope) {
				_ref = _scope.ref
			} else {
				_interps[| i] = undefined
				
				continue
			}
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
	
#region Game Loop
	var _ticks_queued = false
	
	if _in_netgame {
		if _is_master {
			with _netgame {
				if ack_count >= player_count {
					ack_count = 1
					stall_time = 0
					i = 0
					
					repeat ds_list_size(players) {
						var _player = players[| i]
						
						if _player != undefined {
							_player.tick_acked = (i == local_slot)
						}
						
						++i
					}
				} else if ++stall_time >= STALL_RATE {
					_tick = 0
					
					if stall_time >= STALL_RATE + TICKRATE {
						var _text = "[c_yellow]Waiting for: "
						
						i = 0
						
						repeat ds_list_size(players) {
							var _player = players[| i++]
							
							if _player == undefined {
								continue
							}
							
							if not _player.tick_acked {
								_text += _player.name + $" (P{i}) "
							}
						}
						
						show_caption(_text, 3 * (1 / max(_tick_inc, 0.01)))
					}
				}
			}
		} else {
			_tick = _netgame.tick_count
			_ticks_queued = true
			
			if _tick <= 0 and _netgame.load_queue {
				load_level = _netgame.load_level
				load_area = _netgame.load_area
				load_tag = _netgame.load_tag
				load_state = LoadStates.START
				_netgame.load_queue = false
			}
		}
	}
	
	while _tick >= 1 {
		var _skip_tick = false
		
#region Transition
		with proTransition {
			event_user(ThingEvents.TICK)
			
			// Freeze the world while the screen is fading in
			switch state {
				case 1:
					var _transition_canvas = global.transition_canvas
					var _width = window_get_width()
					var _height = window_get_height()
					
					_transition_canvas.Resize(_width, _height)
					_transition_canvas.Start()
					draw_clear(c_black)
					screen_width = _width
					screen_height = _height
					event_user(ThingEvents.DRAW_SCREEN)
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
#endregion
		
#region Cameraman
		if not _skip_tick {
			var _camera_man = global.camera_man
			
			if instance_exists(_camera_man) {
				var _turn_x, _turn_y
				
				with _config {
					_turn_x = in_pan_x * (in_invert_x ? -1 : 1)
					_turn_y = in_pan_y * (in_invert_y ? -1 : 1)
				}
				
				// GROSS HACK: Add analog turning controls to camera by adding
				//			   to mouse delta
				mouse_dx = (mouse_dx * _config.in_mouse_x) + (input_value("aim_right") - input_value("aim_left"))
				mouse_dy = (mouse_dy * _config.in_mouse_y) + (input_value("aim_down") - input_value("aim_up"))
				
				if input_check("attack") {
					_camera_man.roll += mouse_dx * _turn_x
				} else if input_check("aim") {
					_camera_man.fov += mouse_dy * _turn_y
				} else {
					_camera_man.yaw += mouse_dx * _turn_x
					_camera_man.pitch += mouse_dy * _turn_y
				}
				
				if input_check_pressed("inventory_right") {
					_camera_man.roll = 0
					_camera_man.fov = 45
				}
				
				var _move_f = input_value("up") - input_value("down")
				var _move_s = input_value("left") - input_value("right")
				
				if point_distance(0, 0, _move_f, _move_s) > 0 {
					var _len = (2 - input_check("walk")) * (1 + input_check("inventory_up"))
					
					with _camera_man {
						var _forward = lengthdir_3d(_move_f * _len, yaw, pitch)
						
						x += _forward[0]
						y += _forward[1]
						z += _forward[2]
						
						var _side = lengthdir_3d(_move_s * _len, yaw - 90, -roll)
						
						x += _side[0]
						y += _side[1]
						z += _side[2]
					}
				}
				
				_skip_tick = true
			}
		}
#endregion
		
#region UI
		if not _skip_tick {
			_ui = global.ui
			
			if _ui != undefined {
				var _ui_input = global.ui_input
				
				_ui_input[UIInputs.UP_DOWN] = input_check_opposing_pressed("ui_up", "ui_down", 0, true) + input_check_opposing_repeat("ui_up", "ui_down", 0, true, 2, 12)
				_ui_input[UIInputs.LEFT_RIGHT] = input_check_opposing_pressed("ui_left", "ui_right", 0, true) + input_check_opposing_repeat("ui_left", "ui_right", 0, true, 2, 12)
				_ui_input[UIInputs.CONFIRM] = input_check_pressed("ui_enter")
				_ui_input[UIInputs.BACK] = input_check_pressed("pause")
				
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
				
				if _tick_target.exists and _tick_target.f_blocking {
					_skip_tick = true
				}
			} else {
				var _paused = false
				
				if input_check_pressed("pause") {
					_paused = true
					
					if not _in_netgame {
						i = INPUT_MAX_PLAYERS
						
						repeat INPUT_MAX_PLAYERS {
							with _players[--i] {
								if status != PlayerStatus.ACTIVE or get_state("hp") <= 0 {
									break
								}
								
								if not instance_exists(thing) or get_state("frozen") {
									_paused = false
									
									break
								}
							}
							
							if not _paused {
								break
							}
						}
					}
				}
				
				if _paused {
					ui_create("Pause")
					_skip_tick = true
				}
			}
		}
#endregion
		
		if _skip_tick {
			mouse_dx = 0
			mouse_dy = 0
			
			if _in_netgame {
				input_verb_consume("up")
				input_verb_consume("left")
				input_verb_consume("down")
				input_verb_consume("right")
				input_verb_consume("walk")
				input_verb_consume("jump")
				input_verb_consume("interact")
				input_verb_consume("attack")
				input_verb_consume("inventory_up")
				input_verb_consume("inventory_left")
				input_verb_consume("inventory_down")
				input_verb_consume("inventory_right")
				input_verb_consume("aim")
				input_verb_consume("aim_up")
				input_verb_consume("aim_left")
				input_verb_consume("aim_down")
				input_verb_consume("aim_right")
			} else {
				input_clear_momentary(true);
				--_tick
				
				continue
			}
		}
		
#region Demo Playback
		if _playing_demo {
			var _switch_camera = 0
			
			if input_check_pressed("inventory_up") {
				_switch_camera = 1
			} else if input_check_pressed("inventory_left") {
				_switch_camera = 2
			} else if input_check_pressed("inventory_down") {
				_switch_camera = 3
			} else if input_check_pressed("inventory_right") {
				_switch_camera = 4
			} else if input_check_pressed("interact") {
				_switch_camera = 5
			}
			
			switch _switch_camera {
				case 0: break
				
				case 5:
					global.camera_demo = noone
					
					break
				
				default:
					with _players[_switch_camera - 1] {
						if status == PlayerStatus.ACTIVE and area != undefined {
							var _attach
							
							if instance_exists(thing) {
								_attach = area.nearest(thing.x, thing.y, thing.z, DemoCamera)
							} else {
								_attach = area.find(DemoCamera)
							}
							
							global.camera_demo = _attach
						}
					}
			}
			
			var _demo_time = global.demo_time
			
			while _demo_time >= global.demo_next {
				var _break = false
				
				while true {
					switch buffer_read(_demo_buffer, buffer_u8) {
						case DemoPackets.TERMINATE: {
							_break = true
							
							break
						}
						
						case DemoPackets.PLAYER_ACTIVATE: {
							var _slot = buffer_read(_demo_buffer, buffer_u8)
							
							_players[_slot].activate()
							
							break
						}
						
						case DemoPackets.PLAYER_DEACTIVATE: {
							var _slot = buffer_read(_demo_buffer, buffer_u8)
							
							_players[_slot].deactivate()
							
							break
						}
						
						case DemoPackets.PLAYER_INPUT: {
							var _slot = buffer_read(_demo_buffer, buffer_u8)
							var _input = global.demo_input[_slot]
							
							_input[PlayerInputs.UP_DOWN] = buffer_read(_demo_buffer, buffer_s8)
							_input[PlayerInputs.LEFT_RIGHT] = buffer_read(_demo_buffer, buffer_s8)
							
							var _flags = buffer_read(_demo_buffer, buffer_u8)
							
							_input[PlayerInputs.JUMP] = _flags & PIFlags.JUMP
							_input[PlayerInputs.INTERACT] = _flags & PIFlags.INTERACT
							_input[PlayerInputs.ATTACK] = _flags & PIFlags.ATTACK
							_input[PlayerInputs.INVENTORY_UP] = _flags & PIFlags.INVENTORY_UP
							_input[PlayerInputs.INVENTORY_LEFT] = _flags & PIFlags.INVENTORY_LEFT
							_input[PlayerInputs.INVENTORY_DOWN] = _flags & PIFlags.INVENTORY_DOWN
							_input[PlayerInputs.INVENTORY_RIGHT] = _flags & PIFlags.INVENTORY_RIGHT
							_input[PlayerInputs.AIM] = _flags & PIFlags.AIM
							_input[PlayerInputs.AIM_UP_DOWN] = buffer_read(_demo_buffer, buffer_s16)
							_input[PlayerInputs.AIM_LEFT_RIGHT] = buffer_read(_demo_buffer, buffer_s16)
							
							break
						}
						
						case DemoPackets.END: {
							cmd_dend("")
							_demo_buffer = undefined
							_has_demo = false
							_playing_demo = false
							_break = true
							
							break
						}
					}
					
					if _break {
						break
					}
				}
				
				if _has_demo {
					global.demo_next = buffer_read(_demo_buffer, buffer_u32)
				} else {
					break
				}
			}
		}
		
		if _recording_demo {
			buffer_write(_demo_buffer, buffer_u32, global.demo_time)
		}
#endregion
		
#region Players
		var _mouse_dx = mouse_dx
		var _mouse_dy = mouse_dy
		
#region Input
		if _ticks_queued {
			var _tick_queue, _local_slot
			
			with _netgame {
				--tick_count
				_tick_queue = tick_queue
				_local_slot = local_slot
			}
			
			var n = ds_queue_dequeue(_tick_queue)
			
			repeat n {
				var _slot = ds_queue_dequeue(_tick_queue)
				
				with _players[_slot] {
					array_copy(input_previous, 0, input, 0, PlayerInputs.__SIZE)
					
					input[PlayerInputs.UP_DOWN] = ds_queue_dequeue(_tick_queue)
					input[PlayerInputs.LEFT_RIGHT] = ds_queue_dequeue(_tick_queue)
					input[PlayerInputs.JUMP] = ds_queue_dequeue(_tick_queue)
					input[PlayerInputs.INTERACT] = ds_queue_dequeue(_tick_queue)
					input[PlayerInputs.ATTACK] = ds_queue_dequeue(_tick_queue)
					input[PlayerInputs.INVENTORY_UP] = ds_queue_dequeue(_tick_queue)
					input[PlayerInputs.INVENTORY_LEFT] = ds_queue_dequeue(_tick_queue)
					input[PlayerInputs.INVENTORY_DOWN] = ds_queue_dequeue(_tick_queue)
					input[PlayerInputs.INVENTORY_RIGHT] = ds_queue_dequeue(_tick_queue)
					input[PlayerInputs.AIM] = ds_queue_dequeue(_tick_queue)
					input[PlayerInputs.AIM_UP_DOWN] = ds_queue_dequeue(_tick_queue)
					input[PlayerInputs.AIM_LEFT_RIGHT] = ds_queue_dequeue(_tick_queue)
				}
			}
			
			// Main
			var _move_range = input_check("walk") ? 64 : 127
			var _input_up_down = floor((input_value("down") - input_value("up")) * _move_range)
			var _input_left_right = floor((input_value("right") - input_value("left")) * _move_range)
			
			// Main, Inventory, Camera
			var _input_flags = player_input_to_flags(
				input_check("jump"),
				input_check("interact"),
				input_check("attack"),
				input_check("inventory_up"),
				input_check("inventory_left"),
				input_check("inventory_down"),
				input_check("inventory_right"),
				input_check("aim")
			)
			
			// Ugly mouselook/aiming code
			var _dx_factor = input_value("aim_right") - input_value("aim_left")
			var _dy_factor = input_value("aim_down") - input_value("aim_up")
			var _dx_angle, _dy_angle, _dx, _dy
			
			with _config {
				_dx_angle = in_pan_x * (in_invert_x ? -1 : 1)
				_dy_angle = in_pan_y * (in_invert_y ? -1 : 1)
				
				if _mouse_focused {
					_dx_factor += _mouse_dx * in_mouse_x
					_dy_factor += _mouse_dy * in_mouse_y
				}
			}
			
			var _input = _players[_local_slot].input
			
			_dx = round(((_dx_factor * _dx_angle) * 0.0027777777777778) * 32768)
			_dy = round(((_dy_factor * _dy_angle) * 0.0027777777777778) * 32768)
			
			var b = net_buffer_create(false, NetHeaders.CLIENT_INPUT)
			
			buffer_write(b, buffer_s8, _input_up_down)
			buffer_write(b, buffer_s8, _input_left_right)
			buffer_write(b, buffer_u8, _input_flags)
			buffer_write(b, buffer_s16, _dy)
			buffer_write(b, buffer_s16, _dx)
			_netgame.send_host(b)
		} else {
			i = 0
			
			repeat INPUT_MAX_PLAYERS {
				with _players[i] {
					if status != PlayerStatus.ACTIVE {
						break
					}
					
					array_copy(input_previous, 0, input, 0, PlayerInputs.__SIZE)
					
					if _playing_demo {
						var _input = _demo_input[i]
						
						input[PlayerInputs.UP_DOWN] = _input[PlayerInputs.UP_DOWN]
						input[PlayerInputs.LEFT_RIGHT] = _input[PlayerInputs.LEFT_RIGHT]
						input[PlayerInputs.JUMP] = _input[PlayerInputs.JUMP]
						input[PlayerInputs.INTERACT] = _input[PlayerInputs.INTERACT]
						input[PlayerInputs.ATTACK] = _input[PlayerInputs.ATTACK]
						input[PlayerInputs.INVENTORY_UP] = _input[PlayerInputs.INVENTORY_UP]
						input[PlayerInputs.INVENTORY_LEFT] = _input[PlayerInputs.INVENTORY_LEFT]
						input[PlayerInputs.INVENTORY_DOWN] = _input[PlayerInputs.INVENTORY_DOWN]
						input[PlayerInputs.INVENTORY_RIGHT] = _input[PlayerInputs.INVENTORY_RIGHT]
						input[PlayerInputs.AIM] = _input[PlayerInputs.AIM]
						
						var _input_force_up_down = input[PlayerInputs.FORCE_UP_DOWN]
						var _input_force_left_right = input[PlayerInputs.FORCE_LEFT_RIGHT]
						var _input_aim_up_down, _input_aim_left_right
						
						if is_nan(_input_force_up_down) {
							_input_aim_up_down = _input[PlayerInputs.AIM_UP_DOWN]
						} else {
							_input_aim_up_down = round(_input_force_up_down * PLAYER_AIM_DIRECT) % 32768
							input[PlayerInputs.FORCE_UP_DOWN] = NaN
						}
						
						input[PlayerInputs.AIM_UP_DOWN] = _input_aim_up_down
						
						if is_nan(_input_force_left_right) {
							_input_aim_left_right = _input[PlayerInputs.AIM_LEFT_RIGHT]
						} else {
							_input_aim_left_right = round(_input_force_left_right * PLAYER_AIM_DIRECT) % 32768
							input[PlayerInputs.FORCE_LEFT_RIGHT] = NaN
						}
						
						input[PlayerInputs.AIM_LEFT_RIGHT] = _input_aim_left_right
					} else {
						var _get_input = false
						var _pind = i
						
						if _in_netgame {
							if _netgame.local_slot == i {
								_get_input = true
								_pind = 0
							} else {
								if net != undefined {
									var _input_queue = net.input_queue
									
									while ds_queue_size(_input_queue) {
										input[PlayerInputs.UP_DOWN] = ds_queue_dequeue(_input_queue)
										input[PlayerInputs.LEFT_RIGHT] = ds_queue_dequeue(_input_queue)
										input[PlayerInputs.JUMP] = ds_queue_dequeue(_input_queue)
										input[PlayerInputs.INTERACT] = ds_queue_dequeue(_input_queue)
										input[PlayerInputs.ATTACK] = ds_queue_dequeue(_input_queue)
										input[PlayerInputs.INVENTORY_UP] = ds_queue_dequeue(_input_queue)
										input[PlayerInputs.INVENTORY_LEFT] = ds_queue_dequeue(_input_queue)
										input[PlayerInputs.INVENTORY_DOWN] = ds_queue_dequeue(_input_queue)
										input[PlayerInputs.INVENTORY_RIGHT] = ds_queue_dequeue(_input_queue)
										input[PlayerInputs.AIM] = ds_queue_dequeue(_input_queue)
										input[PlayerInputs.AIM_UP_DOWN] = (input[PlayerInputs.AIM_UP_DOWN] - ds_queue_dequeue(_input_queue)) % 32767
										input[PlayerInputs.AIM_LEFT_RIGHT] = (input[PlayerInputs.AIM_LEFT_RIGHT] - ds_queue_dequeue(_input_queue)) % 32767
									}
									
									var _input_force_up_down = input[PlayerInputs.FORCE_UP_DOWN]
									
									if not is_nan(_input_force_up_down) {
										input[PlayerInputs.AIM_UP_DOWN] = round(_input_force_up_down * PLAYER_AIM_DIRECT) % 32768
										input[PlayerInputs.FORCE_UP_DOWN] = NaN
									}
									
									var _input_force_left_right = input[PlayerInputs.FORCE_LEFT_RIGHT]
									
									if not is_nan(_input_force_left_right) {
										input[PlayerInputs.AIM_LEFT_RIGHT] = round(_input_force_left_right * PLAYER_AIM_DIRECT) % 32768
										input[PlayerInputs.FORCE_LEFT_RIGHT] = NaN
									}
								}
							}
						} else {
							_get_input = true
						}
						
						if _get_input {
							// Main
							var _move_range = input_check("walk", _pind) ? 64 : 127
							var _input_up_down = floor((input_value("down", _pind) - input_value("up", _pind)) * _move_range)
							var _input_left_right = floor((input_value("right", _pind) - input_value("left", _pind)) * _move_range)
							var _input_jump = input_check("jump", _pind)
							var _input_interact = input_check("interact", _pind)
							var _input_attack = input_check("attack", _pind)
							
							// Inventory
							var _input_inventory_up = input_check("inventory_up", _pind)
							var _input_inventory_left = input_check("inventory_left", _pind)
							var _input_inventory_down = input_check("inventory_down", _pind)
							var _input_inventory_right = input_check("inventory_right", _pind)
							
							// Camera
							var _input_aim = input_check("aim", _pind)
							
							// Write to input array
							input[PlayerInputs.UP_DOWN] = _input_up_down
							input[PlayerInputs.LEFT_RIGHT] = _input_left_right
							input[PlayerInputs.JUMP] = _input_jump
							input[PlayerInputs.INTERACT] = _input_interact
							input[PlayerInputs.ATTACK] = _input_attack
							input[PlayerInputs.INVENTORY_UP] = _input_inventory_up
							input[PlayerInputs.INVENTORY_LEFT] = _input_inventory_left
							input[PlayerInputs.INVENTORY_DOWN] = _input_inventory_down
							input[PlayerInputs.INVENTORY_RIGHT] = _input_inventory_right
							input[PlayerInputs.AIM] = _input_aim
							
							// This one kinda sucks...
							var _dx_factor = input_value("aim_right", _pind) - input_value("aim_left", _pind)
							var _dy_factor = input_value("aim_down", _pind) - input_value("aim_up", _pind)
							var _dx_angle, _dy_angle
							
							with _config {
								_dx_angle = in_pan_x * (in_invert_x ? -1 : 1)
								_dy_angle = in_pan_y * (in_invert_y ? -1 : 1)
								
								if _pind == 0 and _mouse_focused {
									_dx_factor += _mouse_dx * in_mouse_x
									_dy_factor += _mouse_dy * in_mouse_y
								}
							}
							
							var _input_force_left_right = input[PlayerInputs.FORCE_LEFT_RIGHT]
							var _input_aim_left_right
							
							if is_nan(_input_force_left_right) {
								var _dx = round(((_dx_factor * _dx_angle) * 0.0027777777777778) * 32768)
								
								_input_aim_left_right = (input[PlayerInputs.AIM_LEFT_RIGHT] - _dx) % 32768
							} else {
								_input_aim_left_right = round(_input_force_left_right * PLAYER_AIM_DIRECT) % 32768
								input[PlayerInputs.FORCE_LEFT_RIGHT] = NaN
							}
							
							input[PlayerInputs.AIM_LEFT_RIGHT] = _input_aim_left_right
							
							var _input_force_up_down = input[PlayerInputs.FORCE_UP_DOWN]
							var _input_aim_up_down
							
							if is_nan(_input_force_up_down) {
								var _dy = round(((_dy_factor * _dy_angle) * 0.0027777777777778) * 32768)
								
								_input_aim_up_down = (input[PlayerInputs.AIM_UP_DOWN] - _dy) % 32768
							} else {
								_input_aim_up_down = round(_input_force_up_down * PLAYER_AIM_DIRECT) % 32768
								input[PlayerInputs.FORCE_UP_DOWN] = NaN
							}
							
							input[PlayerInputs.AIM_UP_DOWN] = _input_aim_up_down
						}
						
						if _recording_demo and not array_equals(input, input_previous) {
							buffer_write(_demo_buffer, buffer_u8, DemoPackets.PLAYER_INPUT)
							buffer_write(_demo_buffer, buffer_u8, i)
							buffer_write(_demo_buffer, buffer_s8, _input_up_down)
							buffer_write(_demo_buffer, buffer_s8, _input_left_right)
							buffer_write(_demo_buffer, buffer_u8, player_input_to_flags(_input_jump, _input_interact, _input_attack, _input_inventory_up, _input_inventory_left, _input_inventory_down, _input_inventory_right, _input_aim))
							buffer_write(_demo_buffer, buffer_s16, _input_aim_up_down)
							buffer_write(_demo_buffer, buffer_s16, _input_aim_left_right)
						}
					}
				}
				
				++i
			}
			
			if _in_netgame {
				i = 0
				
				var b = net_buffer_create(true, NetHeaders.HOST_TICK)
				
				with _netgame {
					buffer_write(b, buffer_u8, player_count)
					
					repeat ds_list_size(players) {
						var _player = players[| i++]
						
						if _player != undefined {
							buffer_write(b, buffer_u8, _player.slot)
							
							with _player.player {
								buffer_write(b, buffer_s8, input[PlayerInputs.UP_DOWN])
								buffer_write(b, buffer_s8, input[PlayerInputs.LEFT_RIGHT])
								
								buffer_write(b, buffer_u8, player_input_to_flags(
									input[PlayerInputs.JUMP],
									input[PlayerInputs.INTERACT],
									input[PlayerInputs.ATTACK],
									input[PlayerInputs.INVENTORY_UP],
									input[PlayerInputs.INVENTORY_LEFT],
									input[PlayerInputs.INVENTORY_DOWN],
									input[PlayerInputs.INVENTORY_RIGHT],
									input[PlayerInputs.AIM]
								))
								
								buffer_write(b, buffer_s16, input[PlayerInputs.AIM_UP_DOWN])
								buffer_write(b, buffer_s16, input[PlayerInputs.AIM_LEFT_RIGHT])
							}
						}
					}
					
					send_others(b)
				}
			}
		}
#endregion
		
		i = 0
		
		repeat INPUT_MAX_PLAYERS {
			with _players[i] {
				if status != PlayerStatus.ACTIVE {
					break
				}
				
#region Area
				if area != undefined {
					with area {
						if master != other {
							break
						}
						
						var _players_in_area = players
						
						// Add actors to actor collision grid
						var _bump_grid = bump_grid
						var _bump_lists = bump_lists
						var _bump_x = bump_x
						var _bump_y = bump_y
						var _bump_width = ds_grid_width(_bump_grid)
						var _bump_height = ds_grid_height(_bump_grid)
						var _bump_max_x = _bump_width - 1
						var _bump_max_y = _bump_height - 1
						
						ds_grid_clear(_bump_grid, false)
						
						var j = 0
						
						repeat ds_list_size(active_things) {
							with active_things[| j++] {
								if not f_bump or f_culled or f_frozen {
									continue
								}
								
								var _gx = (x - _bump_x) * COLLIDER_REGION_SIZE_INVERSE
								var _gy = (y - _bump_y) * COLLIDER_REGION_SIZE_INVERSE
								var _gr = bump_radius * COLLIDER_REGION_SIZE_INVERSE
								
								var _gx1 = clamp(floor(_gx - _gr), 0, _bump_max_x)
								var _gy1 = clamp(floor(_gy - _gr), 0, _bump_max_y)
								var _gx2 = clamp(ceil(_gx + _gr), 1, _bump_width)
								var _gy2 = clamp(ceil(_gy + _gr), 1, _bump_height)
								
								var _gi = _gx1
								
								repeat _gx2 - _gx1 {
									var _gj = _gy1
									
									repeat _gy2 - _gy1 {
										var _list = _bump_lists[# _gi, _gj]
										
										if not _bump_grid[# _gi, _gj] {
											_bump_grid[# _gi, _gj] = true
											ds_list_clear(_list)
										}
										
										ds_list_add(_list, self);
										++_gj
									}
									
									++_gi
								}
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
											if instance_exists(thing) and point_distance(thing.x, thing.y, _ox, _oy) < _od {
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
										event_user(ThingEvents.TICK)
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
											if instance_exists(thing) and point_distance(thing.x, thing.y, _ox, _oy) < _od {
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
										event_user(ThingEvents.TICK)
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
			}
#endregion
			
			++i
		}
#endregion
		
		if _level != undefined {
			++_level.time
		}
		
		mouse_dx = 0
		mouse_dy = 0
		input_clear_momentary(true)
		
		if _has_demo {
			++global.demo_time
		}
		
		if _recording_demo {
			buffer_write(_demo_buffer, buffer_u8, DemoPackets.TERMINATE)
		}
		
		--_tick
	}
#endregion
}

global.tick = _tick

#region End Interpolation
var i = ds_list_size(_interps)

if _tick_inc >= 1 or _config.vid_max_fps <= (TICKRATE * _tick_scale) {
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
		} else {
			if weak_ref_alive(_scope) {
				_ref = _scope.ref
			} else {
				_interps[| i] = undefined
				
				continue
			}
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
		} else {
			if weak_ref_alive(_scope) {
				_ref = _scope.ref
			} else {
				_interps[| i] = undefined
				
				continue
			}
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