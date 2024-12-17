if load_state != LoadStates.NONE and instance_exists(proTransition) {
	var _transition_canvas = global.transition_canvas
	
	if _transition_canvas.GetStatus() == CanvasStatus.HAS_DATA {
		_transition_canvas.DrawStretched(0, 0, 480, 270)
	}
	
	exit
}

#region Rendering
var _draw_target = global.ui

while _draw_target != undefined {
	var _child = _draw_target.child
	
	if _child == undefined {
		break
	}
	
	_draw_target = _child
}

var _console = global.console
var _netgame = global.netgame
var _in_netgame = _netgame != undefined and _netgame.active
var d = global.delta

if _draw_target == undefined or _draw_target.f_draw_screen {
	var _width = window_get_width()
	var _height = window_get_height()
	
#region Draw Active Cameras
	var _players_active = global.players_active
	var _num_active = ds_list_size(_players_active)
	var _camera_man = global.camera_man
	var _has_camera_man = thing_exists(_camera_man)
	
	if _has_camera_man {
		_camera_man.render(_width, _height, true).DrawStretched(0, 0, 480, 270)
	} else {
		var _camera_active = global.camera_active
		
		if thing_exists(_camera_active) {
			_camera_active.render(_width, _height, true).DrawStretched(0, 0, 480, 270)
		} else {
			var _camera_demo = global.camera_demo
			
			if thing_exists(_camera_demo) {
				_camera_demo.render(_width, _height, true).DrawStretched(0, 0, 480, 270)
			} else if _in_netgame and _netgame.local_player != undefined {
				with _netgame.local_player {
					if thing_exists(camera) {
						camera.render(_width, _height, true).DrawStretched(0, 0, 480, 270)
					}
				}
			} else switch _num_active {
				case 1: {
					with _players_active[| 0] {
						if thing_exists(camera) {
							camera.render(_width, _height, true).DrawStretched(0, 0, 480, 270)
						}
					}
					
					break
				}
				
				case 2: {
					_height *= 0.5
					
					var _y = 0
					var i = 0
					
					repeat _num_active {
						with _players_active[| i] {
							if thing_exists(camera) {
								camera.render(_width, _height, i == 0).DrawStretched(0, _y, 480, 135)
							}
						}
						
						_y += 135;
						++i
					}
					
					break
				}
				
				case 3:
				case 4: {
					_width *= 0.5
					_height *= 0.5
					
					var _x = 0
					var _y = 0
					var i = 0
					
					repeat _num_active {
						with _players_active[| i] {
							if thing_exists(camera) {
								camera.render(_width, _height, i == 0).DrawStretched(_x, _y, 240, 135)
							}
						}
						
						_x += 240
						
						if _x > _width {
							_x = 0
							_y += 135
						}
						
						++i
					}
					
					break
				}
			}
		}
	}
#endregion

#region Update Particles & Draw GUI
	var _dead_particles = global.dead_particles
	
	var _particle_step = not (
		global.freeze_step
		or (global.netgame == undefined and (_console or (_draw_target != undefined and _draw_target.f_blocking)))
		or (_has_camera_man and global.camera_man_freeze)
	)
	
	var _gui_priority = global.gui_priority
	var i = 0
	
	repeat _num_active {
		var _player = _players_active[| i++]
		
		var _area = _player.area
		
		if _area == undefined or _area.master != _player {
			continue
		}
		
		if _particle_step {
			var _particles = _area.particles
			var j = ds_list_size(_particles)
			
			while j {
				var p = _particles[| --j]
				
				p[ParticleData.TICKS] -= d
				p[ParticleData.X] += p[ParticleData.X_SPEED] * d
				p[ParticleData.Y] += p[ParticleData.Y_SPEED] * d
				
				var _z_speed = p[ParticleData.Z_SPEED]
				var _z = p[ParticleData.Z] + _z_speed * d
				
				p[ParticleData.Z] = _z
				p[ParticleData.X_SPEED] *= power(p[ParticleData.X_FRICTION], d)
				p[ParticleData.Y_SPEED] *= power(p[ParticleData.Y_FRICTION], d)
				p[ParticleData.Z_SPEED] = clamp(_z_speed + (p[ParticleData.GRAVITY] * d), p[ParticleData.MAX_FALL_SPEED] * d, p[ParticleData.MAX_FLY_SPEED] * d) * power(p[ParticleData.Z_FRICTION], d)
				
				_width = p[ParticleData.WIDTH] - p[ParticleData.WIDTH_SPEED] * d
				_height = p[ParticleData.HEIGHT] - p[ParticleData.HEIGHT_SPEED] * d
				
				p[ParticleData.WIDTH] = _width
				p[ParticleData.HEIGHT] = _height
				p[ParticleData.ANGLE] += p[ParticleData.ANGLE_SPEED] * d
				p[ParticleData.PITCH] += p[ParticleData.PITCH_SPEED] * d
				p[ParticleData.ROLL] += p[ParticleData.ROLL_SPEED] * d
				
				var _alpha = p[ParticleData.ALPHA] - p[ParticleData.ALPHA_SPEED] * d
				
				p[ParticleData.ALPHA] = _alpha
				p[ParticleData.BRIGHT] = max(0, p[ParticleData.BRIGHT] - (p[ParticleData.BRIGHT_SPEED] * d))
				
				var _frame = p[ParticleData.FRAME] + p[ParticleData.FRAME_SPEED] * d
				var _animation = p[ParticleData.ANIMATION]
				
				if _animation == ParticleAnimations.PLAY_STAY {
					_frame = min(_frame, p[ParticleData.IMAGE].GetCount() - 1)
				}
				
				p[ParticleData.FRAME] = _frame
				
				if p[ParticleData.TICKS] <= 0 or (_animation == ParticleAnimations.PLAY and _frame >= p[ParticleData.IMAGE].GetCount()) or _width <= 0 or _height <= 0 or _alpha <= 0 or _z > p[ParticleData.FLOOR_Z] or _z < p[ParticleData.CEILING_Z] {
					p[ParticleData.DEAD] = true
				}
				
				if p[ParticleData.DEAD] {
					ds_stack_push(_dead_particles, p)
					ds_list_delete(_particles, j)
				}
			}
		}
		
		var _things = _area.active_things
		var j = 0
		
		repeat ds_list_size(_things) {
			with _things[| j++] {
				if f_visible {
					ds_priority_add(_gui_priority, self, gui_depth)
				}
			}
		}
		
		repeat ds_priority_size(_gui_priority) {
			with ds_priority_delete_max(_gui_priority) {
				gpu_set_depth(gui_depth)
				event_user(ThingEvents.DRAW_GUI)
			}
		}
		
		gpu_set_depth(0)
	}
#endregion
}

// Draw UI
if _draw_target != undefined {
	with _draw_target {
		if draw_gui != undefined {
			catspeak_execute(draw_gui)
		}
	}
}

if instance_exists(proTransition) {
	var _width = window_get_width()
	var _height = window_get_height()
	
	display_set_gui_size(_width, _height)
	
	with proTransition {
		screen_width = _width
		screen_height = _height
		event_user(ThingEvents.DRAW_SCREEN)
	}
	
	display_set_gui_size(480, 270)
}

if _in_netgame {
	with _netgame {
		draw_set_font(global.chat_font)
		
		var _time = current_time
		
		if chat {
			var _input = keyboard_string
			
			if (_time % 1000) < 500 {
				_input += "_"
			}
			
			var _x = string_width(_input)
			
			_x = _x > 224 ? 240 - _x : 16
			draw_text_color(_x - 1, 239, _input, c_black, c_black, c_black, c_black, 0.25)
			draw_text_color(_x, 239, _input, c_black, c_black, c_black, c_black, 0.25)
			draw_text_color(_x + 1, 239, _input, c_black, c_black, c_black, c_black, 0.25)
			draw_text_color(_x - 1, 238, _input, c_black, c_black, c_black, c_black, 0.25)
			draw_text_color(_x, 238, _input, c_black, c_black, c_black, c_black, 0.25)
			draw_text_color(_x + 1, 238, _input, c_black, c_black, c_black, c_black, 0.25)
			draw_text_color(_x - 1, 237, _input, c_black, c_black, c_black, c_black, 0.25)
			draw_text_color(_x, 237, _input, c_black, c_black, c_black, c_black, 0.25)
			draw_text_color(_x + 1, 237, _input, c_black, c_black, c_black, c_black, 0.25)
			draw_text(_x, 238, _input)
		}
		
		draw_set_valign(fa_bottom)
		
		var _max_lines = -~chat * MAX_LINES
		var i = ds_list_size(chat_log)
		var _y = 232
		var _alpha = 1
		var _shadow = 0.25
		
		while _max_lines and i {
			var _message = chat_log[| i - 2]
			var _color = chat_log[| i - 1]
			var _show = true;
			
			--_max_lines
			
			if not chat {
				var _fade_time = chat_fade[_max_lines]
				
				if _time >= _fade_time {
					_show = false
				} else {
					var _fade = min(_fade_time - _time, 1000) * 0.001
					
					_alpha = _fade * 0.75
					_shadow = _fade * 0.25
				}
			}
			
			if _show {
				draw_text_ext_color(15, _y + 1, _message, -1, 224, c_black, c_black, c_black, c_black, _shadow)
				draw_text_ext_color(16, _y + 1, _message, -1, 224, c_black, c_black, c_black, c_black, _shadow)
				draw_text_ext_color(17, _y + 1, _message, -1, 224, c_black, c_black, c_black, c_black, _shadow)
				draw_text_ext_color(15, _y, _message, -1, 224, c_black, c_black, c_black, c_black, _shadow)
				draw_text_ext_color(16, _y, _message, -1, 224, c_black, c_black, c_black, c_black, _shadow)
				draw_text_ext_color(17, _y, _message, -1, 224, c_black, c_black, c_black, c_black, _shadow)
				draw_text_ext_color(15, _y - 1, _message, -1, 224, c_black, c_black, c_black, c_black, _shadow)
				draw_text_ext_color(16, _y - 1, _message, -1, 224, c_black, c_black, c_black, c_black, _shadow)
				draw_text_ext_color(17, _y - 1, _message, -1, 224, c_black, c_black, c_black, c_black, _shadow)
				draw_text_ext_color(16, _y, _message, -1, 224, _color, _color, _color, _color, _alpha);
				_y -= string_height_ext(_message, -1, 224) + 2
			}
			
			i -= 2
		}
		
		draw_set_valign(fa_top)
		draw_set_font(-1)
	}
}

if caption_time > 0 {
	draw_set_alpha(0.5)
	
	with caption {
		draw_rectangle_color(get_left(240) - 1, get_top(240) - 1, get_right(240), get_bottom(240), c_black, c_black, c_black, c_black, false)
		draw_set_alpha(1)
		draw(240, 240)
	}
	
	caption_time -= d
}

if _console {
	draw_set_font(scribble_fallback_font)
	
	var _console_bottom = 160
	
	draw_set_alpha(0.5)
	draw_rectangle_color(0, 0, 480, _console_bottom + 8, c_black, c_black, c_black, c_black, false)
	draw_set_alpha(1)
	
	var _console_log = global.console_log
	var n = ds_list_size(_console_log)
	var i = 0
	var _y = 0
	
	repeat 20 {
		if (_console_bottom - _y) < 0 {
			break
		}
		
		++i
		
		var _str = _console_log[| n - i]
		
		if _str == undefined {
			break
		}
		
		_y += string_height_ext(_str, -1, 960) >> 1
		draw_text_ext_transformed(0, _console_bottom - _y, _str, -1, 960, 0.5, 0.5, 0)
	}
	
	var _input = keyboard_string
	
	if (current_time % 1000) < 500 {
		_input += "_"
	}
	
	var _x = string_width(_input) >> 1
	
	_x = _x > 480 ? 480 - _x : 0
	draw_text_transformed(_x, _console_bottom, _input, 0.5, 0.5, 0)
	draw_set_font(-1)
}

if global.debug_fps {
	var _fps = $"{fps} FPS"
	
	if _in_netgame and not _netgame.master {
		_fps += $"\n{_netgame.delay} ms"
	}
	
	draw_set_alpha(0.5)
	draw_rectangle_color(0, 0, string_width(_fps), string_height(_fps), c_black, c_black, c_black, c_black, false)
	draw_set_alpha(1)
	draw_text(0, 0, _fps)
}

if load_state != LoadStates.NONE and (load_level != undefined or load_state == LoadStates.CONNECT) {
	scribble($"[{ui_font_name}][wave][fa_center][fa_middle]{lexicon_text("loading")}", "__PNENGINE_LOADING__").draw(240, 135)
}
#endregion

#region Audio
#region Play Sound When Focused
if not global.config.snd_background.value {
	if window_has_focus() {
		if not global.audio_focus {
			fmod_channel_control_set_volume(global.master_channel_group, global.master_volume)
			global.audio_focus = true
		}
	} else {
		if global.audio_focus {
			fmod_channel_control_set_volume(global.master_channel_group, 0)
			global.audio_focus = false
		}
	}
}
#endregion

#region Update Sound Pools
with Thing {
	if emitter != undefined {
		emitter_pos.x = sx
		emitter_pos.y = sy
		emitter_pos.z = sz
		
		var i = ds_list_size(emitter)
		
		while i {
			var _sound = emitter[| --i]
			
			if fmod_channel_control_is_playing(_sound) {
				fmod_channel_control_set_3d_attributes(_sound, emitter_pos, emitter_vel)
			} else {
				ds_list_delete(emitter, i)
			}
		}
	}
}

var _sound_pools = global.sound_pools
var i = 0

repeat ds_list_size(_sound_pools) {
	with _sound_pools[| i++] {
		var _update_gain = false
		var j = 0
		
		repeat SOUND_POOL_SLOTS {
			var _gain_time = gain_time[j]
			var _gain_duration = gain_duration[j]
			
			if _gain_time < _gain_duration {
				gain_time[j] = min(_gain_time + (AUDIO_TICKRATE_MILLISECONDS * d), _gain_duration)
				gain[j] = lerp(gain_start[j], gain_end[j], gain_time[j] / _gain_duration)
				_update_gain = true
			}
			
			++j
		}
		
		if _update_gain {
			fmod_channel_control_set_volume(channel_group, gain[0] * gain[1] * gain[2] * gain[3])
		}
	}
}
#endregion

#region Update Music Instances
var _music_instances = global.music_instances

i = ds_list_size(_music_instances)

while i {
	with _music_instances[| --i] {
		var _update_gain = false
		var j = 0
		
		repeat 4 {
			var _gain_time = gain_time[j]
			var _gain_duration = gain_duration[j]
			
			if _gain_time < _gain_duration {
				gain_time[j] = min(_gain_time + (AUDIO_TICKRATE_MILLISECONDS * d), _gain_duration)
				gain[j] = lerp(gain_start[j], gain_end[j], gain_time[j] / _gain_duration)
				_update_gain = true
			}
			
			++j
		}
		
		if _update_gain {
			fmod_channel_control_set_volume(sound_instance, gain[0] * gain[1] * gain[2] * gain[3])
		}
		
		if (stopping and gain[2] <= 0) or not fmod_channel_control_is_playing(sound_instance) {
			destroy()
		}
	}
}
#endregion

fmod_system_update()
#endregion