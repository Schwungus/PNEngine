/// @func ui_load(type)
/// @desc Loads a type of UI for use in the current level.
/// @param {(UI|string)} type The type of UI to load.
function ui_load(_type, _special = undefined) {
	if is_string(_type) {
		var _scripts = global.scripts
		
		_scripts.load(_type, _special)
		
		var _script = _scripts.get(_type)
		
		if _script != undefined and is_instanceof(_script, UIScript) {
			return true
		}
		
		return ui_load(variable_global_get(_type), _special)
	}
	
	if is_instanceof(_type, UI) {
		var _ui = new _type()
		
		_ui.load(_special)
		
		delete _ui
		return true
	}
	
	return false
}