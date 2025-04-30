function proOptionsUI() : UI(undefined) constructor {
	font = global.ui_font ?? -1
	switch_sound = global.switch_sound
	select_sound = global.select_sound
	fail_sound = global.fail_sound
	back_sound = global.back_sound
	
#region Menus
	var _config = global.config
	
	menu = new OUIMenu("options.title", [
#region Controls
		new OUIMenu("options.controls.title", [
			new OUIOption("options.controls.in_invert_x", OUIValues.NO_YES, _config.in_invert_x.value, function (_value) {
				config_set("in_invert_x", _value)
			}),
		
			new OUIOption("options.controls.in_invert_y", OUIValues.NO_YES, _config.in_invert_y.value, function (_value) {
				config_set("in_invert_y", _value)
			}),
		
			new OUISlider("options.controls.in_aim_x", _config.in_aim_x.value, 1, 1, 10, function () {
				return $"{round(current_value * 16.66666666666667)}%" // 100 / 6
			}, function (_value) {
				config_set("in_aim_x", _value)
			}),
		
			new OUISlider("options.controls.in_aim_y", _config.in_aim_y.value, 1, 1, 10, function () {
				return $"{round(current_value * 16.66666666666667)}%" // 100 / 6
			}, function (_value) {
				config_set("in_aim_y", _value)
			}),
		
			undefined,
		
			new OUIOption("options.controls.in_mouse", OUIValues.OFF_ON, _config.in_mouse.value, function (_value) {
				config_set("in_mouse", _value)
			}),
		
			new OUISlider("options.controls.in_mouse_x", _config.in_mouse_x.value, 0.05, 0.05, 2, function () {
				return $"{round(current_value * 100)}%"
			}, function (_value) {
				config_set("in_mouse_x", _value)
			}, function () {
				return not global.config.in_mouse.value
			}),
		
			new OUISlider("options.controls.in_mouse_y", _config.in_mouse_y.value, 0.05, 0.05, 2, function () {
				return $"{round(current_value * 100)}%"
			}, function (_value) {
				config_set("in_mouse_y", _value)
			}, function () {
				return not global.config.in_mouse.value
			}),
		
			undefined,
		
			new OUIOption("options.controls.in_gyro", OUIValues.OFF_ON, _config.in_gyro.value, function (_value) {
				config_set("in_gyro", _value)
			}),
		
			new OUISlider("options.controls.in_gyro_x", _config.in_gyro_x.value, 0.05, 0.05, 2, function () {
				return $"{round(current_value * 100)}%"
			}, function (_value) {
				config_set("in_gyro_x", _value)
			}, function () {
				return not global.config.in_gyro.value
			}),
		
			new OUISlider("options.controls.in_gyro_y", _config.in_gyro_y.value, 0.05, 0.05, 2, function () {
				return $"{round(current_value * 100)}%"
			}, function (_value) {
				config_set("in_gyro_y", _value)
			}, function () {
				return not global.config.in_gyro.value
			}),
		
			undefined,
			new OUIBinding("options.controls.up", INPUT_VERB.UP),
			new OUIBinding("options.controls.left", INPUT_VERB.LEFT),
			new OUIBinding("options.controls.down", INPUT_VERB.DOWN),
			new OUIBinding("options.controls.right", INPUT_VERB.RIGHT),
			new OUIBinding("options.controls.walk", INPUT_VERB.WALK),
			new OUIBinding("options.controls.jump", INPUT_VERB.JUMP),
			new OUIBinding("options.controls.interact", INPUT_VERB.INTERACT),
			new OUIBinding("options.controls.attack", INPUT_VERB.ATTACK),
			undefined,
			new OUIBinding("options.controls.aim", INPUT_VERB.AIM),
			new OUIBinding("options.controls.aim_up", INPUT_VERB.AIM_UP),
			new OUIBinding("options.controls.aim_left", INPUT_VERB.AIM_LEFT),
			new OUIBinding("options.controls.aim_down", INPUT_VERB.AIM_DOWN),
			new OUIBinding("options.controls.aim_right", INPUT_VERB.AIM_RIGHT),
			undefined,
			new OUIBinding("options.controls.inventory1", INPUT_VERB.INVENTORY1),
			new OUIBinding("options.controls.inventory2", INPUT_VERB.INVENTORY2),
			new OUIBinding("options.controls.inventory3", INPUT_VERB.INVENTORY3),
			new OUIBinding("options.controls.inventory4", INPUT_VERB.INVENTORY4),
		]),
#endregion
		
#region Video
		new OUIMenu("options.video.title", [
			new OUIOption("options.video.vid_fullscreen", OUIValues.OFF_ON, _config.vid_fullscreen.value, function (_value) {
				config_set("vid_fullscreen", _value)
			}),
			
			new OUIOption("options.video.vid_resolution", OUIValues.RESOLUTION, function () {
				var _config = global.config
				var _width = _config.vid_width.value
				var _height = _config.vid_height.value
				var _resolution = 0
				var _aspect = (_width / _height) >= (16 / 9)
				
				if _height >= 2160 {
					_resolution = 16
				} else if _height >= 1440 {
					_resolution = 14
				} else if _height >= 1080 {
					_resolution = 12
				} else if _height >= 900 {
					_resolution = 10
				} else if _height >= 720 {
					_resolution = 8
				} else if _height >= 540 {
					_resolution = 6
				} else if _height >= 480 {
					_resolution = 4
				} else if _height >= 270 {
					_resolution = 2
				}
				
				return _resolution + _aspect
			}(), function (_value) {
				var _width, _height
				
				switch _value {
					case 0:
						_width = 320
						_height = 240
						
						break
					
					case 1:
						_width = 426
						_height = 240
						
						break
					
					case 2:
						_width = 360
						_height = 270
						
						break
					
					case 3:
						_width = 480
						_height = 270
						
						break
					
					case 4:
						_width = 640
						_height = 480
						
						break
					
					case 5:
						_width = 854
						_height = 480
						
						break
					
					case 6:
						_width = 720
						_height = 540
						
						break
					
					case 7:
						_width = 960
						_height = 540
						
						break
					
					case 8:
						_width = 960
						_height = 720
						
						break
					
					case 9:
						_width = 1280
						_height = 720
						
						break
					
					case 10:
						_width = 1200
						_height = 900
						
						break
					
					case 11:
						_width = 1600
						_height = 900
						
						break
					
					case 12:
						_width = 1440
						_height = 1080
						
						break
					
					case 13:
						_width = 1920
						_height = 1080
						
						break
					
					case 14:
						_width = 1920
						_height = 1440
						
						break
					
					case 15:
						_width = 2560
						_height = 1440
						
						break
					
					case 16:
						_width = 2880
						_height = 2160
						
						break
					
					case 17:
						_width = 3840
						_height = 2160
						
						break
				}
				
				config_set("vid_width", _width, false)
				config_set("vid_height", _height, false)
			}),
			
			new OUIOption("options.video.vid_max_fps", OUIValues.FRAMERATE, function () {
				var _fps = global.config.vid_max_fps.value
				var _preset
				
				if _fps >= 240 {
					_preset = 6
				} else if _fps >= 165 {
					_preset = 5
				} else if _fps >= 144 {
					_preset = 4
				} else if _fps >= 120 {
					_preset = 3
				} else if _fps >= 75 {
					_preset = 2
				} else if _fps >= 60 {
					_preset = 1
				} else {
					_preset = 0
				}
				
				return _preset
			}(), function (_value) {
				var _fps
				
				switch _value {
					case 0: _fps = 30 break
					default:
					case 1: _fps = 60 break
					case 2: _fps = 75 break
					case 3: _fps = 120 break
					case 4: _fps = 144 break
					case 5: _fps = 165 break
					case 6: _fps = 240 break
				}
				
				config_set("vid_max_fps", _fps)
			}),
			
			new OUIOption("options.video.vid_vsync", OUIValues.OFF_ON, _config.vid_vsync.value, function (_value) {
				config_set("vid_vsync", _value)
			}),
			
			undefined,
			
			new OUIOption("options.video.vid_texture_filter", OUIValues.TEXTURE, _config.vid_texture_filter.value, function (_value) {
				config_set("vid_texture_filter", _value)
			}),
			
			new OUIOption("options.video.vid_mipmap_filter", OUIValues.MIPMAP, _config.vid_mipmap_filter.value, function (_value) {
				config_set("vid_mipmap_filter", _value)
			}),
			
			new OUIOption("options.video.vid_antialias", OUIValues.ANTIALIAS, function () {
				var _aa = global.config.vid_antialias.value
				var _preset
				
				if _aa >= 8 {
					_preset = 3
				} else if _aa >= 4 {
					_preset = 2
				} else if _aa >= 2 {
					_preset = 1
				} else {
					_preset = 0
				}
				
				return _preset
			}(), function (_value) {
				var _aa
				
				switch _value {
					default: _aa = 0 break
					case 1: _aa = 2 break
					case 2: _aa = 4 break
					case 3: _aa = 8 break
				}
				
				config_set("vid_antialias", _aa)
			}),
			
			new OUIOption("options.video.vid_bloom", OUIValues.OFF_ON, _config.vid_bloom.value, function (_value) {
				config_set("vid_bloom", _value)
			}),
			
			undefined,
			
			new OUIOption("options.video.vid_lighting", OUIValues.LEVEL, _config.vid_lighting.value, function (_value) {
				config_set("vid_lighting", _value)
			}),
			
			undefined,
			
			new OUIButton("options.video.apply", function () {
				var _config = global.config
				
				display_set(_config.vid_fullscreen.value, _config.vid_width.value, _config.vid_height.value)
				
				return true
			}),
		]),
#endregion
		
#region Audio
		new OUIMenu("options.audio.title", [
			new OUISlider("options.audio.snd_volume", _config.snd_volume.value, 0.05, 0, 1, function () {
				return $"{current_value * 100}%"
			}, function (_value) {
				config_set("snd_volume", _value)
			}),
			
			new OUISlider("options.audio.snd_sound_volume", _config.snd_volume.value, 0.05, 0, 1, function () {
				return $"{current_value * 100}%"
			}, function (_value) {
				config_set("snd_sound_volume", _value)
			}),
			
			new OUISlider("options.audio.snd_music_volume", _config.snd_volume.value, 0.05, 0, 1, function () {
				return $"{current_value * 100}%"
			}, function (_value) {
				config_set("snd_music_volume", _value)
			}),
			
			undefined,
			
			new OUIOption("options.audio.snd_background", OUIValues.NO_YES, _config.snd_background.value, function (_value) {
				config_set("snd_background", _value)
			}),
		]),
		
		undefined,
		
		new OUIOption("options.language", OUIValues.LANGUAGE, function () {
			var _curl = lexicon_language_get()
			var _languages = global.oui_values[OUIValues.LANGUAGE]
			var i = 0
			var _found = false
			
			repeat array_length(_languages) {
				if _languages[i] == _curl {
					_found = true
					
					break
				}
				
				++i
			}
			
			return _found ? i : 0
		}(), function (_value) {
			config_set("language", global.oui_values[OUIValues.LANGUAGE][_value])
		}),
		
		undefined,
		
		new OUIMenu("options.confirm.save", [
			new OUIText("options.confirm.text"),
			undefined,
			
			new OUIButton("options.confirm.confirm", function () {
				config_save()
				ui_top().replace(proOptionsUI)
				
				return true
			}),
		]),
		
		new OUIMenu("options.confirm.last", [
			new OUIText("options.confirm.text"),
			undefined,
			
			new OUIButton("options.confirm.confirm", function () {
				config_load()
				ui_top().replace(proOptionsUI)
				
				return true
			}),
		]),
		
		new OUIMenu("options.confirm.default", [
			new OUIText("options.confirm.text"),
			undefined,
			
			new OUIButton("options.confirm.confirm", function () {
				config_reset()
				ui_top().replace(proOptionsUI)
				
				return true
			}),
		]),
	])
#endregion
#endregion
	
	focus = undefined
	focus_cooldown = false
	force_option = -1
	device = -1
	
	clean_up = function () {
		InputDeviceStopAllRebinding()
	}
	
	tick = function () {
		if focus != undefined {
			InputVerbConsume(INPUT_VERB.JUMP)
			InputVerbConsume(INPUT_VERB.LEAVE)
			InputVerbConsume(INPUT_VERB.DEBUG_CONSOLE)
			
			if input[UIInputs.BACK] {
				if InputDeviceGetRebinding(device) {
					InputDeviceSetRebinding(device, false)
					InputVerbConsumeAll()
					focus_cooldown = 2
				}
				
				play_sound(back_sound)
				focus = undefined
				
				exit
			}
			
			if is_instanceof(focus, OUIBinding) {
				var _result = InputDeviceGetRebindingResult(device)
				
				if _result != undefined {
					if _result == vk_escape or _result == gp_start {
						play_sound(back_sound)
					} else {
						InputBindingSet(InputDeviceIsGamepad(device), focus.verb, _result)
						play_sound(select_sound)
					}
					
					InputDeviceSetRebinding(device, false)
					InputVerbConsumeAll()
					focus = undefined
					focus_cooldown = 2
				}
			} else if is_instanceof(focus, OUIInput) and input[UIInputs.CONFIRM] /* GROSS HACK */ and not keyboard_check(vk_space) {
				play_sound(focus.confirm(keyboard_string) ? select_sound : fail_sound)
				focus = undefined
			}
			
			exit
		}
		
		// GROSS HACK: Needed for rebinding
		if focus_cooldown {
			--focus_cooldown
			
			exit
		}
		
		if input[UIInputs.BACK] {
			play_sound(back_sound)
			
			var _from = menu.from
			
			if _from == undefined {
				destroy()
			} else {
				menu = _from
			}
			
			exit
		}
		
		if force_option >= 0 {
			menu.option = force_option
			force_option = -1
		} else {
			var _up_down = input[UIInputs.UP_DOWN]
			
			if _up_down != 0 {
				var _changed = false
				
				with menu {
					var n = array_length(contents)
				
					if not n {
						break
					}
					
					var _next = option
					
					while true {
						option = (option + _up_down) % n
						
						while option < 0 {
							option += n
						}
						
						var _element = contents[option]
						
						if is_instanceof(_element, OUIElement) and not is_instanceof(_element, OUIText) and (_element.disabled == undefined or not _element.disabled()) {
							break
						}
					}
					
					if _next != option {
						global.oui_current[? name] = option
						_changed = true
					}
				}
				
				if _changed {
					play_sound(switch_sound)
				}
			}
		}
		
		var _left_right = input[UIInputs.LEFT_RIGHT]
		
		if _left_right != 0 {
			var _selected = false
			
			with menu {
				var _option = contents[option]
				
				if not (is_instanceof(_option, OUIOption) or is_instanceof(_option, OUISlider)) or (_option.disabled != undefined and _option.disabled()) {
					break
				}
				
				_selected = _option.select(_left_right)
			}
			
			play_sound(_selected ? select_sound : fail_sound)
		}
		
		if input[UIInputs.CONFIRM] {
			var _changed = false
			
			with menu {
				var _option = contents[option]
				
				if is_instanceof(_option, OUIElement) and _option.disabled != undefined and _option.disabled() {
					play_sound(fail_sound)
					
					break
				}
				
				if is_instanceof(_option, OUIMenu)  {
					_option.from = other.menu
					other.menu = _option
					_changed = true
				} else if is_instanceof(_option, OUIButton) or is_instanceof(_option, OUIOption) or is_instanceof(_option, OUISlider) {
					_changed = _option.select(1)
					
					if not _changed {
						play_sound(fail_sound)
					}
				} else if is_instanceof(_option, OUIInput) {
					keyboard_string = string(_option.current_value)
					other.focus = _option
					_changed = true
				} else if is_instanceof(_option, OUIBinding) {
					with other {
						static _ignore = [vk_backspace, vk_backtick, gp_select]
						
						focus = _option
						device = InputPlayerGetDevice()
						InputDeviceSetRebinding(device, true, _ignore)
					}
					
					_changed = true
				}
			}
			
			if _changed {
				play_sound(select_sound)
			}
		}
	}
	
	draw_gui = function () {
		draw_set_alpha(0.5)
		draw_rectangle_color(0, 0, 480, 270, c_black, c_black, c_black, c_black, false)
		draw_set_alpha(1)
		
		var _font = font
		
		draw_set_font(_font)
		draw_set_valign(fa_middle)
		
		var _focus = focus
		
		with menu {
			var i = 0
			var _margin = -~string_height(" ")
			var _y = 135 - (option * _margin)
			
			repeat array_length(contents) {
				var _element = contents[i]
				
				if _element == undefined {
					_y += _margin;
					++i
					
					continue
				}
				
				var _color = is_instanceof(_element, OUIText) ? c_white : (option == i ? c_yellow : C_AB_GREEN)
				
				with _element {
					var _alpha = ((disabled != undefined and disabled()) ? 0.5 : 1)
					var _name = lexicon_text(name)
					
					draw_text_color(24, _y, _name, _color, _color, _color, _color, _alpha)
					
					if is_instanceof(_element, OUIOption) {
						draw_text_color(32 + string_width(_name), _y, lexicon_text(values[current_value]), c_white, c_white, c_white, c_white, _alpha)
					} else if is_instanceof(_element, OUISlider) {
						draw_text_color(32 + string_width(_name), _y, (format != undefined ? format : string)(current_value), c_white, c_white, c_white, c_white, _alpha)
					} else if is_instanceof(_element, OUIInput) {
						var _text
						
						if _focus == _element {
							_text = keyboard_string
							
							if (current_time % 1000) >= 500 {
								_text += "_"
							}
						} else {
							_text = current_value
						}
						
						draw_text_color(32 + string_width(_name), _y, _text, c_white, c_white, c_white, c_white, _alpha)
					} else if is_instanceof(_element, OUIBinding) {
						var _text = _focus == _element ? lexicon_text("value.press_any_key") : string_input(verb)
						
						draw_text_color(32 + string_width(_name), _y, _text, c_white, c_white, c_white, c_white, _alpha)
					}
				}
				
				_y += _margin;
				++i
			}
		}
		
		draw_set_valign(fa_top)
		draw_set_halign(fa_right)
		draw_text_transformed(448, 32, lexicon_text(menu.name), 2, 2, 0)
		
		var _indicator = ""
		
		if focus != undefined {
			if is_instanceof(focus, OUIInput) {
				_indicator += $"[{string_input(INPUT_VERB.UI_ENTER)}] {lexicon_text("options.hud.confirm")}"
			}
			
			_indicator += $"\n\n[{string_input(INPUT_VERB.PAUSE)}] {lexicon_text("options.hud.cancel")}"
		} else {
			_indicator += $"[{string_input(INPUT_VERB.UI_UP)}/{string_input(INPUT_VERB.UI_DOWN)}] {lexicon_text("options.hud.select")}"
			_indicator += $"\n\n[{string_input(INPUT_VERB.UI_LEFT)}/{string_input(INPUT_VERB.UI_RIGHT)}] {lexicon_text("options.hud.change")}"
			_indicator += $"\n\n[{string_input(INPUT_VERB.UI_ENTER)}] {lexicon_text("options.hud.confirm")}"
			_indicator += $"\n\n[{string_input(INPUT_VERB.PAUSE)}] {lexicon_text(menu.from != undefined ? "options.hud.back" : "options.hud.exit")}"
		}
		
		draw_set_valign(fa_middle)
		draw_text_color(448, 135, _indicator, c_ltgray, c_ltgray, c_ltgray, c_ltgray, 0.64)
		draw_set_halign(fa_left)
		draw_set_valign(fa_top)
		draw_set_font(-1)
	}
}