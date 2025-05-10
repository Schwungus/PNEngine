/// @func batch_set_bright(bright)
/// @desc Sets the current brightness of the batch. Causes batch breaks.
/// @param {Real} bright Brightness value, ranging from 0 to 1.
function batch_set_bright(_bright) {
	gml_pragma("forceinline")
	
	if _bright != global.batch_bright {
		batch_submit()
		global.batch_bright = _bright
	}
}