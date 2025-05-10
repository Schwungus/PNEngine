/// @func batch_set_blendmode(blendmode)
/// @desc Sets the blending mode for the batch. Causes batch breaks.
/// @param {Constant.BlendMode} blendmode
function batch_set_blendmode(_blendmode) {
	gml_pragma("forceinline")
	
	if _blendmode != global.batch_blendmode {
		batch_submit()
		global.batch_blendmode = _blendmode
	}
}