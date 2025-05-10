/// @func batch_set_filter(filter)
/// @desc Sets texture filtering on the batch. Causes batch breaks.
/// @param {Bool} filter
function batch_set_filter(_filter) {
	gml_pragma("forceinline")
	
	if _filter != global.batch_filter {
		batch_submit()
		global.batch_filter = _filter
	}
}