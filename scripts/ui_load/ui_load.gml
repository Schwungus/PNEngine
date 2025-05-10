/// @func ui_load(type, [special])
/// @desc Loads a type of UI.
/// @param {Function.UI|String} type UI type.
/// @param {Any} [special] Custom properties to specify while loading.
/// @return {Bool} Whether or not the UI was successfully loaded.
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
		var _images = global.images
		var _batch = _images.batch
		
		if not _batch {
			_images.start_batch()
		}
		
		var _ui = new _type()
		
		_ui.load(_special)
		
		delete _ui
		
		if not _batch {
			_images.end_batch()
		}
		
		return true
	}
	
	return false
}