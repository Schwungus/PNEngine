enum TitleOptions {
	NEW_FILE,
	LOAD_FILE,
	DELETE_FILE,
	OPTIONS,
}

event_inherited()
f_unique = true
title_start = global.title_start
menu = undefined
locked = false
save_data = []

#region Constructors
/// @func TitleMenu(name, options, select_disabled)
/// @param {String} name
/// @param {Array<Any>} options
/// @param {Bool} select_disabled
/// @context TitleBase
function TitleMenu(_name, _options, _select_disabled) constructor {
	name = _name
	options = _options
	option = 0
	from = undefined
	select_disabled = _select_disabled
}

/// @func TitleOption(name, function, disabled)
/// @param {String} name
/// @param {Function|Undefined} function
/// @param {Bool} disabled
/// @context TitleBase
function TitleOption(_name, _function, _disabled) constructor {
	name = _name
	func = _function
	disabled = _disabled
}

/// @func TitleSave(save)
/// @param {Struct.Save} save
/// @context TitleBase
function TitleSave(_save) constructor {
	name = _save.name
	code = _save.code
	date = _save.date
	states = variable_clone(_save.states)
	flags = variable_clone(_save.flags)
	level = _save.level
}
#endregion

#region Functions
/// @func add_menu(name, [options], [select_disabled])
/// @param {String} name
/// @param {Array<Any>} [options]
/// @param {bool} [select_disabled]
/// @return {Struct.TitleMenu}
/// @context TitleBase
add_menu = function (_name, _options = [], _select_disabled = false) {
	return new TitleMenu(_name, _options, _select_disabled)
}

/// @func add_option(name, [function], [disabled])
/// @param {String} name
/// @param {Function|Enum.TitleOptions|Undefined} [function]
/// @param {bool} [disabled]
/// @return {Struct.TitleOption}
/// @context TitleBase
add_option = function (_name, _function = undefined, _disabled = false) {
	if _function == TitleOptions.DELETE_FILE {
		_disabled = not array_length(save_data)
	}
	
	return new TitleOption(_name, _function, _disabled)
}

/// @func set_menu(menu, [allow_return])
/// @param {Struct.TitleMenu} menu
/// @param {Bool} [allow_return]
/// @return {Bool}
/// @context TitleBase
set_menu = function (_menu, _allow_return = true) {
	if _menu != undefined and not global.title_delete_state {
		with _menu {
			if _allow_return {
				from = other.menu
			}
			
			var n = array_length(options)
			
			if n {
				var _option = options[option]
				
				while _option == undefined or (not select_disabled and _option.disabled) {
					option = -~option % n
					_option = options[option]
				}
			}
		}
		
		var _previous = menu
		
		menu = _menu
		catspeak_execute(change_menu, _previous)
		
		return true
	}
	
	return false
}

/// @func goto(level, area, tag, transition)
/// @param {String} level
/// @param {Real} area
/// @param {Real} tag
/// @param {Asset.GMObject|String} transition
/// @context TitleBase
goto = function (_level, _area, _tag, _transition) {
	// This is a safe method for entering a level through the title.
	global.level.goto(_level, _area, _tag, _transition)
}
#endregion

#region Virtual Functions
change_menu = function (_previous) {}

/// @func change_option(previous)
/// @param {Real} previous
/// @context TitleBase
change_option = function (_previous) {}

/// @func change_delete_state(state)
/// @param {Real} state
/// @context TitleBase
change_delete_state = function (_state) {}

/// @func exit_title(option)
/// @param {Real} option
/// @context TitleBase
exit_title = function (_option) {}
#endregion

#region Events
Thing_event_create = event_create
Thing_event_tick = event_tick

event_create = function () {
	var _saves = global.saves
	
	ds_list_clear(_saves)
	
	var _name = file_find_first(SAVES_PATH + "*.sav", fa_none)
	
	while _name != "" {
		print($"TitleBase: Found '{_name}'")
		
		var _save = new Save(_name)
		
		if _save.code != "SAVE_MODS" {
			ds_list_add(_saves, _save)
			array_push(save_data, new TitleSave(_save))
		}
		
		_name = file_find_next()
	}
	
	file_find_close()
	Thing_event_create()
	global.title_start = false
	global.title_delete_state = 0
	global.save_name = "Debug"
}

event_tick = function () {
	Thing_event_tick()

	if menu != undefined and not locked {
		if global.console {
			exit
		}
	
		var _ui = global.ui
	
		while _ui != undefined {
			with _ui {
				if f_blocking or f_block_input {
					exit
				}
			
				_ui = child
			}
		}
	
		var _change_option = InputOpposingRepeat(INPUT_VERB.UI_UP, INPUT_VERB.UI_DOWN)
	
		if _change_option != 0 and global.title_delete_state <= 1 {
			var _previous = menu.option
			var _new_option
		
			with menu {
				var n = array_length(options)
			
				if n {
					_new_option = _previous
				
					while true {
						option = (option + _change_option) % n
					
						if option < 0 {
							option += n
						}
					
						var _option = options[option]
					
						if _option != undefined and (select_disabled or not _option.disabled) {
							break
						}
					}
				
					_new_option = _new_option != option
				}
			}
		
			if _new_option {
				catspeak_execute(change_option, _previous)
			}
		}
	
		// Select option
		if InputPressed(INPUT_VERB.UI_ENTER) {
			var _curopt = menu.option
			var _options = menu.options
			var _option = _options[_curopt]
			var _function = _option.func
		
			if is_numeric(_function) {
				var _exit = false
			
				switch _function {
					case TitleOptions.NEW_FILE: {
						if global.title_delete_state {
							break
						}
					
						var i = 1
					
						while file_exists(SAVES_PATH + $"File {i}.sav") {
							++i
						}
					
						global.global_flags.clear()
					
						var _players = global.players
						var j = 0
					
						repeat MAX_PLAYERS {
							_players[j++].clear_states()
						}
					
						global.save_name = $"File {i}"
						_exit = true
					
						break
					}
				
					case TitleOptions.LOAD_FILE: {
						if global.title_delete_state >= 1 {
							var _title_delete_state = -~global.title_delete_state
						
							if _title_delete_state == 3 {
								array_delete(_options, _curopt, 1)
							
								var _save = save_data[_curopt]
							
								file_delete(SAVES_PATH + _save.name + ".sav")
								array_delete(save_data, _curopt, 1)
								_title_delete_state = 0
							
								while _options[0] == undefined {
									array_shift(_options)
								}
							
								while _options[menu.option] == undefined {
									if --menu.option < 0 {
										menu.option += array_length(_options)
									}
								}
							}
						
							catspeak_execute(change_delete_state, _title_delete_state)
							global.title_delete_state = _title_delete_state
						
							break
						}
					
						var _save = global.saves[| _curopt]
					
						if _save == undefined or _save.code != "" {
							break
						}
					
						with _save {
							global.save_name = name
						
							var _players = global.players
							var i = 0
						
							repeat MAX_PLAYERS {
								_players[i++].clear_states()
							}
						
							i = 0
						
							repeat array_length(states) {
								var _player = _players[i]
								var _states = states[i]
								var _names = struct_get_names(_states)
								var j = 0
							
								repeat struct_names_count(_states) {
									var _key = _names[j]
								
									_player.set_state(_key, _states[$ _key]);
									++j
								}
							
								++i
							}
						
							var _global = global.global_flags
							var _names = struct_get_names(flags)
						
							_global.clear()
							i = 0
						
							repeat struct_names_count(flags) {
								var _key = _names[i]
							
								_global.set(_key, flags[$ _key]);
								++i
							}
						
							var _checkpoint = global.checkpoint
						
							_checkpoint[0] = level
							_checkpoint[1] = area
							_checkpoint[2] = tag
						}
					
						_exit = true
					
						break
					}
				
					case TitleOptions.DELETE_FILE: {
						catspeak_execute(change_delete_state, 1)
						global.title_delete_state = 1
					
						break
					}
				
					case TitleOptions.OPTIONS: {
						ui_create(proOptionsUI)
						_exit = true
					
						break
					}
				}
			
				if _exit {
					catspeak_execute(exit_title, _function)
				}
			} else {
				if is_method(_function) {
					catspeak_execute(_function)
				}
			}
		}
	
		// Return to previous menu
		if InputPressed(INPUT_VERB.PAUSE) {
			if global.title_delete_state {
				catspeak_execute(change_delete_state, -1)
				global.title_delete_state = -1
			} else {
				set_menu(menu.from, false)
			}
		}
	}
}
#endregion