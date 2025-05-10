/// @func thing_exists(thing)
/// @param {Id.Instance} thing
/// @return {Bool}
function thing_exists(_thing) {
	gml_pragma("forceinline")
	
	return instance_exists(_thing) and not _thing.f_destroyed
}