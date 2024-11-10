switch load_state {
	case LoadStates.START: {
		var _netgame = global.netgame
		
		if _netgame != undefined and _netgame.master and _netgame.player_count > 1 {
			with _netgame {
				var i = 0
				
				repeat ds_list_size(players) {
					var _player = players[| i++]
					
					if _player == undefined {
						continue
					}
					
					_player.ready = (_player == local_net)
				}
			}
		}
		
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
					
					var _players_ready = global.players_ready
					
					ds_list_delete(_players_ready, ds_list_find_index(_players_ready, self))
					ds_list_add(global.players_active, self)
				}
			}
		}
		
		if global.demo_write and global.demo_buffer == undefined {
			var _demo_buffer = buffer_create(1, buffer_grow, 1)
			
			// Header
			buffer_write(_demo_buffer, buffer_string, "PNEDEMO")
			buffer_write(_demo_buffer, buffer_string, GM_version)
			
			/* Add a special integer to check if this was recorded during a
			   netgame. (0 = local, 1 = host, 2 = client)
			   Some mods may have special behaviour on netgames, so this is
			   required. */
			buffer_write(_demo_buffer, buffer_u8, net_active() + (not net_master()))
			
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
			
			// Level & flags
			buffer_write(_demo_buffer, buffer_string, load_level)
			buffer_write(_demo_buffer, buffer_u32, load_area)
			buffer_write(_demo_buffer, buffer_s32, load_tag)
			global.flags[FlagGroups.GLOBAL].write(_demo_buffer)
			global.demo_buffer = _demo_buffer
			print("proControl: Recording demo")
		}
		
		np_setpresence_timestamps(_level.rp_time ? date_current_datetime() : 0, 0, false)
		i = 0
		
		repeat INPUT_MAX_PLAYERS {
			with _players[i++] {
				if status == PlayerStatus.ACTIVE {
					set_area(_load_area, _load_tag)
				}
			}
		}
		
		var _netgame = global.netgame
		
		if _netgame != undefined {
			if _netgame.master {
				var _player_count = _netgame.player_count
				
				if _player_count > 1 {
					print($"proControl: Waiting for {_player_count} players")
					load_state = LoadStates.HOST_WAIT
				}
			} else {
				_netgame.send_host(net_buffer_create(true, NetHeaders.CLIENT_READY))
			}
		}
		
		exit
	}
	
	case LoadStates.CONNECT: {
		// This is a dummy load state that waits until the netgame connection
		// returns a result.
		exit
	}
	
	case LoadStates.HOST_WAIT: {
		var _netgame = global.netgame
		
		if _netgame != undefined and _netgame.master and _netgame.player_count > 1 {
			with _netgame {
				var i = 0
				
				repeat ds_list_size(players) {
					var _player = players[| i++]
					
					if _player == undefined {
						continue
					}
					
					if not _player.ready {
						exit
					}
				}
			}
		}
		
		load_state = LoadStates.NONE
		
		break
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
	__input_system_tick()
	
	// Cache game session info
	var _demo_write = global.demo_write
	var _demo_buffer = global.demo_buffer
	var _playing_demo = not _demo_write and _demo_buffer != undefined
	var _recording_demo = _demo_write and _demo_buffer != undefined
	var _netgame = global.netgame
	var _in_netgame = _netgame != undefined and _netgame.active
	var _is_master = not _in_netgame or _netgame.master
	
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
	
	var _local_connections = input_players_get_status()
	var _local_changed = _local_connections.__any_changed and not (_playing_demo or _in_netgame)
	
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
	
#region Tick Loop
	var _tick_buffer = global.tick_buffer
	var _tick_size = 0
	
	// Cache player stuff
	var _players = global.players
	var _players_active = global.players_active
	var _level = global.level
	
#region Netgame Pre-Processing
	if _in_netgame {
		if _is_master {
			with _netgame {
				// You can stall the game if there are too many reliable
				// packets queued up, but I don't think that's necessary.
				//var _dont_stall = false
				
				if ack_count >= player_count {
					ack_count = 1
					stall_time = 0
					//_dont_stall = true
					i = 0
					
					repeat ds_list_size(players) {
						var _player = players[| i]
						
						if _player != undefined {
							_player.tick_acked = (i == local_slot)
							
							/*if i == local_slot {
								_player.tick_acked = true
							} else {
								_player.tick_acked = false
								
								if ds_list_size(_player.reliable) > TICKRATE {
									_dont_stall = false
								}
							}*/
						}
						
						++i
					}
				}
				
				/*if _dont_stall {
					stall_time = 0
				}*/
				
				stall_time += _tick
				
				if stall_time >= STALL_RATE {
					_tick = 0
					
					if stall_time >= (STALL_RATE + TICKRATE) {
						var _text = "[c_yellow]Waiting for: "
						
						i = 0
						
						repeat ds_list_size(players) {
							var _player = players[| i++]
							
							if _player == undefined {
								continue
							}
							
							with _player {
								if not tick_acked {
									_text += name + $" (P{i}) "
								}
							}
						}
						
						show_caption(_text, 3 * (1 / max(_tick_inc, 0.01)))
					}
				}
			}
		} else {
			var _client_tick = _tick
			
			_tick = min(_netgame.tick_count, STALL_RATE)
			
			if _tick > 0 {
				with _netgame {
					if local_player != undefined {
						with local_player {
							if instance_exists(thing) {
								with thing {
									if predict_host == undefined {
										break
									}
									
									x = predict_host.x
									y = predict_host.y
									z = predict_host.z
									angle = predict_host.angle
									pitch = predict_host.pitch
									x_speed = predict_host.x_speed
									y_speed = predict_host.y_speed
									z_speed = predict_host.z_speed
									vector_speed = predict_host.vector_speed
									move_angle = predict_host.move_angle
									last_prop = predict_host.last_prop
									fric = predict_host.fric
									grav = predict_host.grav
									max_fall_speed = predict_host.max_fall_speed
									max_fly_speed = predict_host.max_fly_speed
									radius = predict_host.radius
									height = predict_host.height
									array_copy(floor_ray, 0, predict_host.floor_ray, 0, RaycastData.__SIZE)
									array_copy(wall_ray, 0, predict_host.wall_ray, 0, RaycastData.__SIZE)
									array_copy(ceiling_ray, 0, predict_host.ceiling_ray, 0, RaycastData.__SIZE)
									input_length = predict_host.input_length
									jumped = predict_host.jumped
									coyote = predict_host.coyote
									aim_angle = predict_host.aim_angle
									movement_speed = predict_host.movement_speed
									jump_speed = predict_host.jump_speed
									coyote_time = predict_host.coyote_time
									f_grounded = predict_host.f_grounded
									playcam_z_lerp = predict_host.playcam_z_lerp
									playcam_z_snap = predict_host.playcam_z_snap
									playcam_sync_input = predict_host.playcam_sync_input
									array_copy(playcam_target, 0, predict_host.playcam_target, 0, CameraTargetData.__SIZE)
									array_copy(playcam, 0, predict_host.playcam, 0, 3)
									playcam_z = predict_host.playcam_z
									playcam_z_to = predict_host.playcam_z_to
									
									if model != undefined {
										model.x = predict_host.model_x
										model.y = predict_host.model_y
										model.z = predict_host.model_z
										model.yaw = predict_host.model_yaw
										model.pitch = predict_host.model_pitch
										model.roll = predict_host.model_roll
									}
								}
							}
							
							if instance_exists(camera) {
								with camera {
									if predict_host == undefined {
										break
									}
									
									x = predict_host.x
									y = predict_host.y
									z = predict_host.z
									angle = predict_host.angle
									pitch = predict_host.pitch
									x_speed = predict_host.x_speed
									y_speed = predict_host.y_speed
									z_speed = predict_host.z_speed
									vector_speed = predict_host.vector_speed
									move_angle = predict_host.move_angle
									last_prop = predict_host.last_prop
									fric = predict_host.fric
									grav = predict_host.grav
									max_fall_speed = predict_host.max_fall_speed
									max_fly_speed = predict_host.max_fly_speed
									radius = predict_host.radius
									height = predict_host.height
									array_copy(floor_ray, 0, predict_host.floor_ray, 0, RaycastData.__SIZE)
									array_copy(wall_ray, 0, predict_host.wall_ray, 0, RaycastData.__SIZE)
									array_copy(ceiling_ray, 0, predict_host.ceiling_ray, 0, RaycastData.__SIZE)
									f_grounded = predict_host.f_grounded
									yaw = predict_host.yaw
									roll = predict_host.roll
									fov = predict_host.fov
									range = predict_host.range
									range_lerp = predict_host.range_lerp
									
									if model != undefined {
										model.x = predict_host.model_x
										model.y = predict_host.model_y
										model.z = predict_host.model_z
										model.yaw = predict_host.model_yaw
										model.pitch = predict_host.model_pitch
										model.roll = predict_host.model_roll
									}
								}
							}
						}
					}
					
					delay = 0
					stall_time = 0
				}
			}
			
			_netgame.stall_time += _client_tick
			
			//while _client_tick >= 1 {
				// Main
				var _move_range = input_check("walk") ? 64 : 127
				var _input_up_down = floor((input_value("down") - input_value("up")) * _move_range)
				var _input_left_right = floor((input_value("right") - input_value("left")) * _move_range)
				var _input_jump = input_check("jump")
				var _input_interact = input_check("interact")
				var _input_attack = input_check("attack")
				
				// Inventory
				var _input_inventory_up = input_check("inventory_up")
				var _input_inventory_left = input_check("inventory_left")
				var _input_inventory_down = input_check("inventory_down")
				var _input_inventory_right = input_check("inventory_right")
				
				// Camera
				var _input_aim = input_check("aim")
				var _dx_factor = input_value("aim_right") - input_value("aim_left")
				var _dy_factor = input_value("aim_down") - input_value("aim_up")
				var _dx_angle, _dy_angle
				var _mouse_dx = mouse_dx
				var _mouse_dy = mouse_dy
				
				with _config {
					_dx_angle = in_pan_x * (in_invert_x ? -1 : 1)
					_dy_angle = in_pan_y * (in_invert_y ? -1 : 1)
					
					if _mouse_focused {
						_dx_factor += _mouse_dx * in_mouse_x
						_dy_factor += _mouse_dy * in_mouse_y
					}
				}
				
				var _dx = round(((_dx_factor * _dx_angle) * 0.0027777777777778) * 32768)
				var _dy = round(((_dy_factor * _dy_angle) * 0.0027777777777778) * 32768)
				
				_netgame.send_host(net_buffer_create(false, NetHeaders.CLIENT_INPUT,
					buffer_s8, _input_up_down,
					buffer_s8, _input_left_right,
					
					buffer_u8, player_input_to_flags(
						_input_jump,
						_input_interact,
						_input_attack,
						_input_inventory_up,
						_input_inventory_left,
						_input_inventory_down,
						_input_inventory_right,
						_input_aim
					),
					
					buffer_s16, _dx % 32768,
					buffer_s16, _dy % 32768
				));
				
				//--_client_tick
			//}
			
			if _netgame.stall_time >= (STALL_RATE + TICKRATE) {
				show_caption("[c_yellow]Waiting for host", 3 * (1 / max(_tick_inc, 0.01)))
			}
		}
	}
#endregion
	
	var _ticked = false
	
	while _tick >= 1 {
		var _skip_tick = false
		
		// Transition (Non-deterministic, do not rely on its outcome)
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
		
		// UI (Non-deterministic, do not rely on its outcome)
		if not _skip_tick {
			_ui = global.ui
			
			if _ui != undefined {
				var _ui_input = global.ui_input
				
				_ui_input[UIInputs.UP_DOWN] = input_check_opposing_pressed("ui_up", "ui_down", 0, true) + input_check_opposing_repeat("ui_up", "ui_down", 0, true, 2, 12)
				_ui_input[UIInputs.LEFT_RIGHT] = input_check_opposing_pressed("ui_left", "ui_right", 0, true) + input_check_opposing_repeat("ui_left", "ui_right", 0, true, 2, 12)
				_ui_input[UIInputs.CONFIRM] = input_check_pressed("ui_enter")
				_ui_input[UIInputs.BACK] = input_check_pressed("pause")
				
				if _mouse_focused {
					_ui_input[UIInputs.MOUSE_X] = (window_mouse_get_x() / window_get_width()) * 480
					_ui_input[UIInputs.MOUSE_Y] = (window_mouse_get_y() / window_get_height()) * 270
					_ui_input[UIInputs.MOUSE_CONFIRM] = input_check_pressed("ui_click")
				} else {
					_ui_input[UIInputs.MOUSE_CONFIRM] = false
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
				
				if _tick_target.exists and _tick_target.f_blocking {
					_skip_tick = true
				}
				
				// Extra check to prevent a crash when disconnecting
				// through UI leave() method
				if _in_netgame and not net_active() {
					_in_netgame = false
					_is_master = true
					_skip_tick = true
				}
			} else {
				var _paused = false
				
				if input_check_pressed("pause") {
					_paused = true
					
					if not _in_netgame {
						i = ds_list_size(_players_active)
						
						while i {
							with _players_active[| --i] {
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
					ui_create("Pause", {level: _level})
					
					_skip_tick = true
				}
			}
			
			if (_in_netgame or global.game_status & GameStatus.NETGAME) and _skip_tick {
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
				_skip_tick = false
			}
		}
		
		// Write to tick buffer
		if global.inject_tick_buffer {
			global.inject_tick_buffer = false
		} else {
			buffer_seek(_tick_buffer, buffer_seek_start, 0)
		}
		
		// Handle player activations inside the tick
		if _local_changed {
			with _local_connections {
				var i = 0
				
				repeat array_length(__new_connections) {
					buffer_write(_tick_buffer, buffer_u8, TickPackets.ACTIVATE)
					buffer_write(_tick_buffer, buffer_u8, __new_connections[i]);
					++i
				}
				
				i = 0
				
				repeat array_length(__new_disconnections) {
					buffer_write(_tick_buffer, buffer_u8, TickPackets.DEACTIVATE)
					buffer_write(_tick_buffer, buffer_u8, __new_disconnections[i]);
					++i
				}
			}
			
			_local_changed = false
		}
		
		if not _skip_tick {
			if _playing_demo {
				_tick_size = buffer_read(_demo_buffer, buffer_u32)
				
				if _tick_size == 0xFFFFFFFF {
					cmd_dend("")
					_demo_buffer = undefined
					_playing_demo = false
					_tick = 0
					
					break
				}
				
				var _pos = buffer_tell(_demo_buffer)
				
				buffer_copy(_demo_buffer, _pos, _tick_size, _tick_buffer, 0)
				buffer_seek(_demo_buffer, buffer_seek_relative, _tick_size)
				buffer_resize(_tick_buffer, _tick_size)
			} else if _is_master {
				// Local input
				var i = 0
				var _mouse_dx = mouse_dx
				var _mouse_dy = mouse_dy
				
				repeat ds_list_size(_players_active) {
					with _players_active[| i++] {
						var j = slot
						var _input_up_down, _input_left_right, _input_flags, _dx, _dy
						
						if _in_netgame and j > 0 {
							_input_up_down = input[PlayerInputs.UP_DOWN]
							_input_left_right = input[PlayerInputs.LEFT_RIGHT]
							
							_input_flags = player_input_to_flags(
								input[PlayerInputs.JUMP],
								input[PlayerInputs.INTERACT],
								input[PlayerInputs.ATTACK],
								input[PlayerInputs.INVENTORY_UP],
								input[PlayerInputs.INVENTORY_LEFT],
								input[PlayerInputs.INVENTORY_DOWN],
								input[PlayerInputs.INVENTORY_RIGHT],
								input[PlayerInputs.AIM]
							)
							
							_dx = 0
							_dy = 0
							
							with net {
								while ds_queue_size(input_queue) {
									_input_up_down = ds_queue_dequeue(input_queue)
									_input_left_right = ds_queue_dequeue(input_queue)
									_input_flags = ds_queue_dequeue(input_queue)
									_dx += ds_queue_dequeue(input_queue)
									_dy += ds_queue_dequeue(input_queue)
								}
							}
						} else {
							// Main
							var _move_range = input_check("walk", j) ? 64 : 127
							
							_input_up_down = floor((input_value("down", j) - input_value("up", j)) * _move_range)
							_input_left_right = floor((input_value("right", j) - input_value("left", j)) * _move_range)
							
							_input_flags = player_input_to_flags(
								input_check("jump", j),
								input_check("interact", j),
								input_check("attack", j),
								input_check("inventory_up", j),
								input_check("inventory_left", j),
								input_check("inventory_down", j),
								input_check("inventory_right", j),
								input_check("aim", j)
							)
							
							// Camera
							var _dx_factor = input_value("aim_right", j) - input_value("aim_left", j)
							var _dy_factor = input_value("aim_down", j) - input_value("aim_up", j)
							var _dx_angle, _dy_angle
							
							with _config {
								_dx_angle = in_pan_x * (in_invert_x ? -1 : 1)
								_dy_angle = in_pan_y * (in_invert_y ? -1 : 1)
								
								if j == 0 and _mouse_focused {
									_dx_factor += _mouse_dx * in_mouse_x
									_dy_factor += _mouse_dy * in_mouse_y
								}
							}
							
							_dx = round(((_dx_factor * _dx_angle) * 0.0027777777777778) * 32768)
							_dy = round(((_dy_factor * _dy_angle) * 0.0027777777777778) * 32768)
						}
						
						buffer_write(_tick_buffer, buffer_u8, TickPackets.INPUT)
						buffer_write(_tick_buffer, buffer_u8, j)
						buffer_write(_tick_buffer, buffer_s8, _input_up_down)
						buffer_write(_tick_buffer, buffer_s8, _input_left_right)
						buffer_write(_tick_buffer, buffer_u8, _input_flags)
						buffer_write(_tick_buffer, buffer_s16, (input[PlayerInputs.AIM_LEFT_RIGHT] - _dx) % 32768)
						buffer_write(_tick_buffer, buffer_s16, (input[PlayerInputs.AIM_UP_DOWN] - _dy) % 32768)
					}
				}
				
				if _in_netgame or _recording_demo {
					with _level {
						if name != "lvlTitle" and (time % 15) == 0 {
							var _checksum = 0
							
							with Thing {
								_checksum += 1 + floor(x) + floor(y) + floor(z)
							}
							
							buffer_write(_tick_buffer, buffer_u8, TickPackets.CHECKSUM)
							buffer_write(_tick_buffer, buffer_u8, abs(time + _checksum) % 256)
						}
					}
				}
				
				_tick_size = buffer_tell(_tick_buffer)
				
				if _in_netgame {
					var b = net_buffer_create(true, NetHeaders.HOST_TICK)
					var _pos = buffer_tell(b)
					
					buffer_copy(_tick_buffer, 0, _tick_size, b, _pos)
					_netgame.send_others(b, _pos + _tick_size)
				}
			} else {
				with _netgame {
					var _time = current_time
					
					delay += _time - ds_queue_dequeue(tick_queue)
					timestamp = _time
					
					var _relay = ds_queue_dequeue(tick_queue)
					
					_tick_size = buffer_get_size(_relay)
					buffer_copy(_relay, 0, _tick_size, _tick_buffer, 0)
					buffer_delete(_relay);
					--tick_count
				}
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
								if __show_reconnect_caption {
									var _device = input_player_get_gamepad_type(_slot)
									
									if _device == "unknown" {
										_device = "no controller"
									}
									
									show_caption($"[c_lime]{lexicon_text("hud.caption.player.reconnect", -~_slot)} ({_device})")
								} else {
									__show_reconnect_caption = true
								}
							}
						}
						
						break
					}
					
					case TickPackets.DEACTIVATE: {
						var _slot = buffer_read(_tick_buffer, buffer_u8)
						
						with _players[_slot] {
							if not player_deactivate(self) {
								show_caption($"[c_red]{lexicon_text("hud.caption.player.last_disconnect", -~_slot)}")
							}
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
							input[PlayerInputs.INVENTORY_UP] = (_input_flags & PIFlags.INVENTORY_UP) != 0
							input[PlayerInputs.INVENTORY_LEFT] = (_input_flags & PIFlags.INVENTORY_LEFT) != 0
							input[PlayerInputs.INVENTORY_DOWN] = (_input_flags & PIFlags.INVENTORY_DOWN) != 0
							input[PlayerInputs.INVENTORY_RIGHT] = (_input_flags & PIFlags.INVENTORY_RIGHT) != 0
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
						
						_tick = 0
						
						break
					}
					
					case TickPackets.CHECKSUM: {
						var _checksum = buffer_read(_tick_buffer, buffer_u8)
						
						if not _is_master or _playing_demo {
							var _clientsum = 0
							
							with Thing {
								_clientsum += 1 + floor(x) + floor(y) + floor(z)
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
						var _sender = _slot < INPUT_MAX_PLAYERS ? _players[_slot] : undefined
						var _name = buffer_read(_tick_buffer, buffer_string)
						var _argc = buffer_read(_tick_buffer, buffer_u8)
						var _args = global.signal_args
						
						array_resize(_args, _argc)
						
						var i = 0
						
						repeat _argc {
							_args[i++] = buffer_read_dynamic(_tick_buffer)
						}
						
						var _handlers = global.handlers
						
						i = ds_list_size(_handlers)
						
						while i {
							with _handlers[| --i] {
								if ui_signalled != undefined {
									catspeak_execute(ui_signalled, _sender, _name, _args)
								}
							}
						}
					}
				}
			}
			
#region Game Loop
			var i = ds_list_size(_players_active)
			
			while i {
				with _players_active[| --i] {
#region Force Aim
					var _input_force_x = input[PlayerInputs.FORCE_LEFT_RIGHT]
					
					if not is_nan(_input_force_x) {
						input[PlayerInputs.AIM_LEFT_RIGHT] = round(_input_force_x * PLAYER_AIM_DIRECT) % 32768
						input[PlayerInputs.FORCE_LEFT_RIGHT] = NaN
					}
					
					var _input_force_y = input[PlayerInputs.FORCE_UP_DOWN]
					
					if not is_nan(_input_force_y) {
						input[PlayerInputs.AIM_UP_DOWN] = round(_input_force_y * PLAYER_AIM_DIRECT) % 32768
						input[PlayerInputs.FORCE_UP_DOWN] = NaN
					}
#endregion
					
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
#endregion
				}
			}
			
			if _level != undefined {
				++_level.time
			}
#endregion
		}
		
		mouse_dx = 0
		mouse_dy = 0
		input_clear_momentary(true)
		_ticked = true;
		--_tick
	}
#endregion
	
#region Client Prediction
	if not _is_master {
		var _local_player = _netgame.local_player
		
		if _local_player != undefined {
			with _local_player {
				var _has_thing = instance_exists(thing)
				var _has_camera = instance_exists(camera)
				
				if _ticked {
					if _has_thing {
						with thing {
							predict_host ??= {
								floor_ray: raycast_data_create(),
								wall_ray: raycast_data_create(),
								ceiling_ray: raycast_data_create(),
								playcam: array_create(3),
								playcam_target: array_create(CameraTargetData.__SIZE),
							}
							
							predict_host.x = x
							predict_host.y = y
							predict_host.z = z
							predict_host.angle = angle
							predict_host.pitch = pitch
							predict_host.x_speed = x_speed
							predict_host.y_speed = y_speed
							predict_host.z_speed = z_speed
							predict_host.vector_speed = vector_speed
							predict_host.move_angle = move_angle
							predict_host.last_prop = last_prop
							predict_host.fric = fric
							predict_host.grav = grav
							predict_host.max_fall_speed = max_fall_speed
							predict_host.max_fly_speed = max_fly_speed
							predict_host.radius = radius
							predict_host.height = height
							array_copy(predict_host.floor_ray, 0, floor_ray, 0, RaycastData.__SIZE)
							array_copy(predict_host.wall_ray, 0, wall_ray, 0, RaycastData.__SIZE)
							array_copy(predict_host.ceiling_ray, 0, ceiling_ray, 0, RaycastData.__SIZE)
							predict_host.input_length = input_length
							predict_host.jumped = jumped
							predict_host.coyote = coyote
							predict_host.aim_angle = aim_angle
							predict_host.movement_speed = movement_speed
							predict_host.jump_speed = jump_speed
							predict_host.coyote_time = coyote_time
							predict_host.f_grounded = f_grounded
							predict_host.playcam_z_lerp = playcam_z_lerp
							predict_host.playcam_z_snap = playcam_z_snap
							predict_host.playcam_sync_input = playcam_sync_input
							array_copy(predict_host.playcam_target, 0, playcam_target, 0, CameraTargetData.__SIZE)
							array_copy(predict_host.playcam, 0, playcam, 0, 3)
							predict_host.playcam_z = playcam_z
							predict_host.playcam_z_to = playcam_z_to
							
							if model != undefined {
								predict_host.model_x = model.x
								predict_host.model_y = model.y
								predict_host.model_z = model.z
								predict_host.model_yaw = model.yaw
								predict_host.model_pitch = model.pitch
								predict_host.model_roll = model.roll
							}
						}
					}
					
					if _has_camera {
						with camera {
							predict_host ??= {
								floor_ray: raycast_data_create(),
								wall_ray: raycast_data_create(),
								ceiling_ray: raycast_data_create(),
							}
							
							predict_host.x = x
							predict_host.y = y
							predict_host.z = z
							predict_host.angle = angle
							predict_host.pitch = pitch
							predict_host.x_speed = x_speed
							predict_host.y_speed = y_speed
							predict_host.z_speed = z_speed
							predict_host.vector_speed = vector_speed
							predict_host.move_angle = move_angle
							predict_host.last_prop = last_prop
							predict_host.fric = fric
							predict_host.grav = grav
							predict_host.max_fall_speed = max_fall_speed
							predict_host.max_fly_speed = max_fly_speed
							predict_host.radius = radius
							predict_host.height = height
							array_copy(predict_host.floor_ray, 0, floor_ray, 0, RaycastData.__SIZE)
							array_copy(predict_host.wall_ray, 0, wall_ray, 0, RaycastData.__SIZE)
							array_copy(predict_host.ceiling_ray, 0, ceiling_ray, 0, RaycastData.__SIZE)
							predict_host.f_grounded = f_grounded
							predict_host.yaw = yaw
							predict_host.roll = roll
							predict_host.fov = fov
							predict_host.range = range
							predict_host.range_lerp = range_lerp
							
							if model != undefined {
								predict_host.model_x = model.x
								predict_host.model_y = model.y
								predict_host.model_z = model.z
								predict_host.model_yaw = model.yaw
								predict_host.model_pitch = model.pitch
								predict_host.model_roll = model.roll
							}
						}
					}
				}
				
				var _input = input
				var _delay = min(_netgame.delay * 0.03, STALL_RATE)
				var _net_interp = _config.net_interp
				var _net_interp_delay = _config.net_interp_delay
				
				if _has_thing {
					with thing {
						if f_frozen or f_culled or predict_host == undefined {
							break
						}
						
						f_predicting = true
						
						// Store original input
						var _input_up_down = _input[PlayerInputs.UP_DOWN]
						var _input_left_right = _input[PlayerInputs.LEFT_RIGHT]
						var _input_jump = _input[PlayerInputs.JUMP]
						var _input_interact = _input[PlayerInputs.INTERACT]
						var _input_attack = _input[PlayerInputs.ATTACK]
						var _input_inventory_up = _input[PlayerInputs.INVENTORY_UP]
						var _input_inventory_left = _input[PlayerInputs.INVENTORY_LEFT]
						var _input_inventory_down = _input[PlayerInputs.INVENTORY_DOWN]
						var _input_inventory_right = _input[PlayerInputs.INVENTORY_RIGHT]
						var _input_aim = _input[PlayerInputs.AIM]
						
						// Tick in prediction mode
						var _move_range = input_check("walk") ? 64 : 127
						
						_input[PlayerInputs.UP_DOWN] = floor((input_value("down") - input_value("up")) * _move_range)
						_input[PlayerInputs.LEFT_RIGHT] = floor((input_value("right") - input_value("left")) * _move_range)
						_input[PlayerInputs.JUMP] = input_check("jump")
						_input[PlayerInputs.INTERACT] = input_check("interact")
						_input[PlayerInputs.ATTACK] = input_check("attack")
						_input[PlayerInputs.INVENTORY_UP] = input_check("inventory_up")
						_input[PlayerInputs.INVENTORY_LEFT] = input_check("inventory_left")
						_input[PlayerInputs.INVENTORY_DOWN] = input_check("inventory_down")
						_input[PlayerInputs.INVENTORY_RIGHT] = input_check("inventory_right")
						_input[PlayerInputs.AIM] = input_check("aim")
						
						var i = _delay
						
						while i >= _net_interp_delay {
							event_user(ThingEvents.TICK);
							--i
						}
						
						x = lerp(predict_host.x, x, _net_interp)
						y = lerp(predict_host.y, y, _net_interp)
						z = lerp(predict_host.z, z, _net_interp)
						angle = lerp_angle(predict_host.angle, angle, _net_interp)
						pitch = lerp_angle(predict_host.pitch, pitch, _net_interp)
						aim_angle = lerp_angle(predict_host.aim_angle, aim_angle, _net_interp)
						
						if model != undefined {
							model.x = lerp(predict_host.model_x, model.x, _net_interp)
							model.y = lerp(predict_host.model_y, model.y, _net_interp)
							model.z = lerp(predict_host.model_z, model.z, _net_interp)
							model.yaw = lerp_angle(predict_host.model_yaw, model.yaw, _net_interp)
							model.pitch = lerp_angle(predict_host.model_pitch, model.pitch, _net_interp)
							model.roll = lerp_angle(predict_host.model_roll, model.roll, _net_interp)
						}
						
						_input[PlayerInputs.UP_DOWN] = _input_up_down
						_input[PlayerInputs.LEFT_RIGHT] = _input_left_right
						_input[PlayerInputs.JUMP] = _input_jump
						_input[PlayerInputs.INTERACT] = _input_interact
						_input[PlayerInputs.ATTACK] = _input_attack
						_input[PlayerInputs.INVENTORY_UP] = _input_inventory_up
						_input[PlayerInputs.INVENTORY_LEFT] = _input_inventory_left
						_input[PlayerInputs.INVENTORY_DOWN] = _input_inventory_down
						_input[PlayerInputs.INVENTORY_RIGHT] = _input_inventory_right
						_input[PlayerInputs.AIM] = _input_aim
						f_predicting = false
					}
				}
				
				if _has_camera {
					with camera {
						if f_frozen or f_culled or path_active or predict_host == undefined {
							break
						}
						
						f_predicting = true
						
						var i = _delay
						
						while i >= _net_interp_delay {
							event_user(ThingEvents.TICK);
							--i
						}
						
						x = lerp(predict_host.x, x, _net_interp)
						y = lerp(predict_host.y, y, _net_interp)
						z = lerp(predict_host.z, z, _net_interp)
						angle = lerp_angle(predict_host.angle, angle, _net_interp)
						pitch = lerp_angle(predict_host.pitch, pitch, _net_interp)
						yaw = lerp_angle(predict_host.yaw, yaw, _net_interp)
						roll = lerp_angle(predict_host.roll, roll, _net_interp)
						fov = lerp(predict_host.fov, fov, _net_interp)
						
						if model != undefined {
							model.x = lerp(predict_host.model_x, model.x, _net_interp)
							model.y = lerp(predict_host.model_y, model.y, _net_interp)
							model.z = lerp(predict_host.model_z, model.z, _net_interp)
							model.yaw = lerp_angle(predict_host.model_yaw, model.yaw, _net_interp)
							model.pitch = lerp_angle(predict_host.model_pitch, model.pitch, _net_interp)
							model.roll = lerp_angle(predict_host.model_roll, model.roll, _net_interp)
						}
						
						f_predicting = false
					}
				}
			}
		}
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