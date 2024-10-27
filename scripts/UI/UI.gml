function UI(_ui_script) constructor {
	exists = true
	ui_script = _ui_script
	
	load = undefined
	create = undefined
	clean_up = undefined
	tick = undefined
	draw_gui = undefined
	
	if _ui_script != undefined {
		load = _ui_script[$ "load"]
		create = _ui_script[$ "create"]
		clean_up = _ui_script[$ "clean_up"]
		tick = _ui_script[$ "tick"]
		draw_gui = _ui_script[$ "draw_gui"]
	}
	
	parent = undefined
	child = undefined
	special = undefined
	
	input = global.ui_input
	
	f_blocking = true
	f_draw_screen = true
	
	static destroy = function () {
		if not exists {
			return false
		}
		
		if ui_exists(parent) {
			parent.child = undefined
		}
		
		if ui_exists(child) {
			child.destroy()
			child = undefined
		}
		
		if clean_up != undefined {
			catspeak_execute(clean_up)
		}
		
		if global.ui == self {
			global.ui = undefined
			
			if not global.console {
				fmod_channel_control_set_paused(global.world_channel_group, false)
			}
		}
		
		exists = false
		
		return true
	}
	
	static link = function (_type, _special = undefined) {
		gml_pragma("forceinline")
		
		if ui_exists(child) {
			child.destroy()
		}
		
		var _ui = ui_create(_type, _special, false)
		
		if ui_exists(_ui) {
			child = _ui
			_ui.parent = self
		}
		
		return _ui
	}
	
	static replace = function (_type, _special = undefined) {
		gml_pragma("forceinline")
		
		return ui_exists(parent) ? parent.link(_type) : ui_create(_type, _special, global.ui == self)
	}
	
	static is_ancestor = function (_type) {
		gml_pragma("forceinline")
		
		return ui_script.is_ancestor(_type)
	}
	
	static play_sound = function (_sound, _loop = false, _offset = 0, _pitch = 1) {
		gml_pragma("forceinline")
		
		return global.ui_sounds.play(_sound, _loop, _offset, _pitch)
	}
	
	static open_options = function () {
		gml_pragma("forceinline")
		
		return link(proOptionsUI)
	}
	
	static goto = function (_level, _area = 0, _tag = ThingTags.NONE, _transition = noone) {
		global.level.goto(_level, _area, _tag, _transition)
	}
	
	static leave = function (_level, _area = 0, _tag = ThingTags.NONE, _transition = noone) {
		cmd_disconnect("")
		global.level.goto(_level, _area, _tag, _transition)
	}
	
	static send_signal = function (_name) {}
}