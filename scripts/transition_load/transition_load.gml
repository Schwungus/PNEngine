/// @func transition_load(type)
/// @desc Loads a type of Transition.
/// @param {Asset.GMObject|String} Transition type.
/// @return {Bool} Whether or not the Transition was successfully loaded.
function transition_load(_type) {
	if is_string(_type) {
		var _scripts = global.scripts
		
		_scripts.load(_type)
		
		var _script = _scripts.get(_type)
		
		if _script != undefined and is_instanceof(_script, TransitionScript) {
			return true
		}
		
		return transition_load(asset_get_index(_type))
	}
	
	if object_exists(_type) {
		var _images = global.images
		var _batch = _images.batch
		
		if not _batch {
			_images.start_batch()
		}
		
		with instance_create_depth(0, 0, 0, _type) {
			event_load()
			instance_destroy(self, false)
		}
		
		if not _batch {
			_images.end_batch()
		}
		
		return true
	}
	
	return false
}