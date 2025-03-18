/// @func thing_load(type)
/// @desc Loads a type of Thing for use in the current level.
/// @param {(Asset.GMObject|string)} type The type of Thing to load.
function thing_load(_type, _special = undefined) {
	if is_string(_type) {
		var _scripts = global.scripts
		
		_scripts.load(_type, _special)
		
		var _script = _scripts.get(_type)
		
		if _script != undefined and is_instanceof(_script, ThingScript) {
			return true
		}
		
		return thing_load(asset_get_index(_type), _special)
	}
	
	if object_exists(_type) {
		var _images = global.images
		var _batch = _images.batch
		
		if not _batch {
			_images.start_batch()
		}
		
		with instance_create_depth(0, 0, 0, _type) {
			special = _special
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