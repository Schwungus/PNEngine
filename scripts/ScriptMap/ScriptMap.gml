function ScriptMap() : AssetMap() constructor {
	static load = function (_name, _special = undefined) {
		if ds_map_exists(assets, _name) {
			with assets[? _name] {
				if is_instanceof(self, ThingScript) {
					thing_load(internal_parent, _special)
				}
				
				if parent != undefined {
					other.load(parent.name, _special)
				}
				
				var i = 0
				
				repeat array_length(imports) {
					other.load(imports[i++].name, _special)
				}
				
				if load != undefined {
					try {
						load(_special)
					} catch (e) {
						show_error($"!!! ScriptMap.load: Error while loading assets from script '{_name}': {e.longMessage}", true)
					}
				}
			}
			
			exit
		}
		
		var _path = "scripts/" + _name
		var _script_file = mod_find_file(_path + ".*")
		
		if _script_file == "" {
			print($"! ScriptMap.load: '{_name}' not found")
			
			exit
		}
		
		var _script
		
		_script_file = file_text_open_read(_script_file)
		
		var _code = ""
		var _line = ""
		var _lines = 0
		var _omit_line = true
		var _type_header_exists = false
		var _macros = []
		
		try {
			while not file_text_eof(_script_file) {
				_omit_line = false
				
				_line = string_trim(file_text_read_string(_script_file))
				file_text_readln(_script_file);
				++_lines
				
				if string_starts_with(_line, "#thing") {
#region Thing
					if _type_header_exists {
						throw $"Cannot have more than one type header, found '{_line}'"
					}
					
					var _index = asset_get_index(_name)
					
					if object_exists(_index) and object_is_ancestor(_index, Thing) {
						throw "Cannot override internal Thing of the same name"
					}
					
					_script = new ThingScript()
					
					var _parents = string_split(_line, " ", true)
					var _parents_n = array_length(_parents)
					
					if _parents_n >= 2 {
						if _parents_n > 2 {
							throw "Cannot inherit more than one Thing"
						}
						
						var _parent = _parents[1]
						
						load(_parent, _special)
						
						with _script {
							parent = other.get(_parent)
							
							if parent == undefined {
								_index = asset_get_index(_parent)
								
								if not object_exists(_index) {
									throw $"Unknown parent Thing '{_parent}'"
								}
								
								if not object_is_ancestor(_index, Thing) {
									throw $"Cannot inherit non-Thing '{_parent}'"
								}
								
								if string_starts_with(_parent, "pro") {
									throw $"Cannot inherit protected Thing '{_parent}'"
								}
								
								internal_parent = _index
							}
							
							if parent != undefined {
								internal_parent = parent.internal_parent
								main = parent.main
								load = parent.load
								create = parent.create
								on_destroy = parent.on_destroy
								clean_up = parent.clean_up
								tick_start = parent.tick_start
								tick = parent.tick
								tick_end = parent.tick_end
								draw = parent.draw
								draw_screen = parent.draw_screen
								draw_gui = parent.draw_gui
							}
							
							thing_load(internal_parent, _special)
						}
					}
					
					_type_header_exists = true
					_omit_line = true
#endregion
				} else if string_starts_with(_line, "#handler") {
#region Handler
					if _type_header_exists {
						throw $"Cannot have more than one type header, found '{_line}'"
					}
					
					_script = new HandlerScript()
					
					var _parents = string_split(_line, " ", true)
					var _parents_n = array_length(_parents)
					
					if _parents_n >= 2 {
						if _parents_n > 2 {
							throw "Cannot inherit more than one Handler"
						}
						
						var _parent = _parents[1]
						
						load(_parent)
						
						with _script {
							parent = other.get(_parent)
							
							if parent == undefined {
								throw $"Parent '{_parent}' not found"
							} else {
								if not is_instanceof(parent, HandlerScript) {
									throw $"Cannot inherit non-Handler '{_parent}'"
								}
								
								main = parent.main
								load = parent.load
								on_register = parent.on_register
								on_start = parent.on_start
								player_activated = parent.player_activated
								player_deactivated = parent.player_deactivated
								level_started = parent.level_started
								level_loading = parent.level_loading
								area_activated = parent.area_activated
								area_deactivated = parent.area_deactivated
								area_changed = parent.area_changed
								ui_signalled = parent.ui_signalled
							}
						}
					}
					
					_type_header_exists = true
					_omit_line = true
#endregion
				} else if string_starts_with(_line, "#transition") {
#region Transition
					if _type_header_exists {
						throw $"Cannot have more than one type header, found '{_line}'"
					}
					
					var _index = asset_get_index(_name)
						
					if object_exists(_index) and object_is_ancestor(_index, proTransition) {
						throw "Cannot override internal Transition of the same name"
					}
					
					_script = new TransitionScript()
					
					var _parents = string_split(_line, " ", true)
					var _parents_n = array_length(_parents)
					
					if _parents_n >= 2 {
						if _parents_n > 2 {
							throw "Cannot inherit more than one TransitionScript"
						}
						
						var _parent = _parents[1]
						
						load(_parent)
						
						with _script {
							parent = other.get(_parent)
							
							if parent == undefined {
								_index = asset_get_index(_parent)
								
								if not object_exists(_index) {
									throw $"Unknown parent Transition '{_parent}'"
								}
								
								if not object_is_ancestor(_index, Thing) {
									throw $"Cannot inherit non-Transition '{_parent}'"
								}
								
								if string_starts_with(_parent, "pro") {
									throw $"Cannot inherit protected Transition '{_parent}'"
								}
								
								internal_parent = _index
							}
							
							if parent != undefined {
								internal_parent = parent.internal_parent
								main = parent.main
								load = parent.load
								reload = parent.reload
								create = parent.create
								clean_up = parent.clean_up
								tick = parent.tick
								draw_screen = parent.draw_screen
							}
							
							transition_load(internal_parent)
						}
					}
					
					_type_header_exists = true
					_omit_line = true
#endregion
				} else if string_starts_with(_line, "#mixin") {
#region Mixin
					if _type_header_exists {
						throw $"Cannot have more than one type header, found '{_line}'"
					}
					
					_script = new MixinScript()
					_type_header_exists = true
					_omit_line = true
#endregion
				} else if string_starts_with(_line, "#import") {
#region Import Mixin(s)
					var _mixins = string_split(_line, " ", true)
					var n = array_length(_mixins) - 1
					
					if not n {
						throw "No mixin specified in #import"
					}
					
					var i = 1
					
					repeat n {
						var _mixin = _mixins[i++]
						
						load(_mixin, _special)
						
						var _import = get(_mixin)
						
						if _import == undefined {
							throw $"Mixin '{_mixin}' not found"
						}
						
						if not is_instanceof(_import, MixinScript) {
							throw $"Cannot import non-mixin '{_mixin}'"
						}
						
						array_push(_script.imports, _import)
					}
					
					_omit_line = true
#endregion
				} else if string_starts_with(_line, "#macro") {
#region Macro
					var _macro = string_split(_line, " ", true, 2)
					
					array_push(_macros, [string_trim(_macro[1]), string_trim(_macro[2])])
					_omit_line = true
#endregion
				} else if string_starts_with(_line, "#ui") {
#region UI
					if _type_header_exists {
						throw $"Cannot have more than one type header, found '{_line}'"
					}
					
					var _index = variable_global_get(_name)
					
					if _index != undefined and is_instanceof(_index, UI) {
						throw "Cannot override internal UI of the same name"
					}
					
					_script = new UIScript()
					
					var _parents = string_split(_line, " ", true)
					var _parents_n = array_length(_parents)
					
					if _parents_n >= 2 {
						if _parents_n > 2 {
							throw "Cannot inherit more than one UI"
						}
						
						var _parent = _parents[1]
						
						load(_parent)
						
						with _script {
							parent = other.get(_parent)
							
							if parent == undefined {
								_index = variable_global_get(_parent)
								
								if _index == undefined {
									throw $"Unknown parent UI '{_parent}'"
								}
								
								if not is_instanceof(_index, UI) {
									throw $"Cannot inherit non-UI '{_parent}'"
								}
								
								if string_starts_with(_parent, "pro") {
									throw $"Cannot inherit protected UI '{_parent}'"
								}
								
								internal_parent = _index
							}
							
							if parent != undefined {
								internal_parent = parent.internal_parent
								main = parent.main
								load = parent.load
								create = parent.create
								clean_up = parent.clean_up
								tick = parent.tick
								draw_gui = parent.draw_gui
							}
							
							ui_load(internal_parent)
						}
					}
					
					_type_header_exists = true
					_omit_line = true
#endregion
				}
				
				if _omit_line {
					_line = ""
				}
				
				_code += _line + chr(13) + chr(10)
			}
		} catch (e) {
			show_error($"!!! ScriptMap.load: Error in '{_name}' at line {_lines}: {e.longMessage}", true)
		}
		
		if not _type_header_exists {
			show_error($"!!! ScriptMap.load: '{_name}' has no type headers", true)
		}
		
		// GROSS HACK: Implement macros by replacing every substring in the
		//             code
		var i = 0
		
		repeat array_length(_macros) {
			var _macro = _macros[i++]
			
			_code = string_replace_all(_code, _macro[0], _macro[1])
		}
		
		file_text_close(_script_file)
		
		var _hir, _main
		
		try {
			_hir = Catspeak.parseString(_code)
		} catch (e) {
			show_error($"!!! ScriptMap: Error while parsing script '{_name}'\n\n{e.longMessage}", true)
		}
		
		try {
			_main = Catspeak.compile(_hir)
		} catch (e) {
			show_error($"!!! ScriptMap: Error while compiling script '{_name}'\n\n{e.longMessage}", true)
		}
		
		var _globals = catspeak_globals(_main)
		
		var _imports = _script.imports
		
		i = 0
		
		repeat array_length(_imports) {
			var _import = _imports[i++]
			
			_globals[$ _import.name] = catspeak_globals(_import.main)
		}
		
		var _parent = _script.parent
		
		if _parent != undefined {
			var _parent_globals = catspeak_globals(_parent.main)
			var _parent_globals_names = struct_get_names(_parent_globals)
			
			i = 0
			
			repeat struct_names_count(_parent_globals) {
				var _key = _parent_globals_names[i++]
				
				_globals[$ _key] = _parent_globals[$ _key]
			}
		}
		
		_main()
		
		with _script {
			name = _name
			main = _main
			load = _globals[$ "load"]
			
			if is_instanceof(self, ThingScript) {
				create = _globals[$ "create"]
				on_destroy = _globals[$ "on_destroy"]
				clean_up = _globals[$ "clean_up"]
				tick_start = _globals[$ "tick_start"]
				tick = _globals[$ "tick"]
				tick_end = _globals[$ "tick_end"]
				draw = _globals[$ "draw"]
				draw_screen = _globals[$ "draw_screen"]
				draw_gui = _globals[$ "draw_gui"]
			} else if is_instanceof(self, HandlerScript) {
				on_register = _globals[$ "on_register"]
				on_start = _globals[$ "on_start"]
				player_activated = _globals[$ "player_activated"]
				player_deactivated = _globals[$ "player_deactivated"]
				level_started = _globals[$ "level_started"]
				level_loading = _globals[$ "level_loading"]
				area_changed = _globals[$ "area_changed"]
				area_activated = _globals[$ "area_activated"]
				area_deactivated = _globals[$ "area_deactivated"]
				ui_signalled = _globals[$ "ui_signalled"]
			} else if is_instanceof(self, TransitionScript) {
				reload = _globals[$ "reload"]
				create = _globals[$ "create"]
				clean_up = _globals[$ "clean_up"]
				tick = _globals[$ "tick"]
				draw_screen = _globals[$ "draw_screen"]
			} else if is_instanceof(self, MixinScript) {
				create = _globals[$ "create"]
			} else if is_instanceof(self, UIScript) {
				create = _globals[$ "create"]
				clean_up = _globals[$ "clean_up"]
				tick = _globals[$ "tick"]
				draw_gui = _globals[$ "draw_gui"]
			}
			
			if load != undefined {
				try {
					load(_special)
				} catch (e) {
					show_error($"!!! ScriptMap.load: Error while loading assets from script '{_name}': {e.longMessage}", true)
				}
			}
		}
		
		ds_map_add(assets, _name, _script)
		print("ScriptMap.load: Added '{0}' ({1})", _name, _script)
	}
}

global.scripts = new ScriptMap()