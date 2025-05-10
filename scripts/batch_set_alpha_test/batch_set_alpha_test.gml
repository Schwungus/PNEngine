/// @func batch_set_alpha_test(threshold)
/// @desc Sets the current alpha testing threshold of the batch. Causes batch breaks.
/// @param {Real} threshold Alpha threshold ranging from 0 to 1. 0 means alpha testing is disabled.
function batch_set_alpha_test(_threshold) {
	gml_pragma("forceinline")
	
	if _threshold != global.batch_alpha_test {
		batch_submit()
		global.batch_alpha_test = _threshold
	}
}