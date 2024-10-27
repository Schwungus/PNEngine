function ui_create(_type, _special = undefined, _replace = true) {
	if _replace {
		var _ui = global.ui
		
		if _ui != undefined {
			_ui.destroy()
		}
	}
	
	var _ui_script = global.scripts.get(_type)
	var _internal_parent = undefined
	
	if is_string(_type) {
		if _ui_script != undefined {
			_internal_parent = _ui_script.internal_parent
		} else {
			_internal_parent = variable_global_get(_type)
			
			if _internal_parent == undefined or not is_instanceof(_internal_parent, UI) {
				show_error($"!!! ui_create: '{_type}' not found", true)
			}
		}
	} else {
		var _test = new _type()
		
		if not is_instanceof(_test, UI) {
			show_error($"!!! ui_create: '{_type}' is not a UI", true)
		}
		
		delete _test
		
		_internal_parent = _type
	}
	
	var _ui = new _internal_parent(_ui_script)
	
	with _ui {
		special = _special
		
		if create != undefined {
			catspeak_execute(create)
		}
		
		if not exists {
			return undefined
		}
	}
	
	if _replace {
		global.ui = _ui
		
		if _ui.f_blocking {
			fmod_channel_control_set_paused(global.world_channel_group, true)
		}
	}
	
	return _ui
}