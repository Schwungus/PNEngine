/// @func batch_set_properties([alpha_test], [bright], [blendmode], [filter])
/// @desc Sets/resets all batch properties. Causes batch breaks.
/// @param {Real} [alpha_test] Alpha threshold ranging from 0 to 1. 0 means alpha testing is disabled.
/// @param {Real} [bright] Brightness value ranging from 0 to 1.
/// @param {Constant.BlendMode} [blendmode] Blending mode.
/// @param {Bool} [filter] Texture filtering.
function batch_set_properties(_alpha_test = 0, _bright = 0, _blendmode = bm_normal, _filter = true) {
	gml_pragma("forceinline")
	
	batch_set_alpha_test(_alpha_test)
	batch_set_bright(_bright)
	batch_set_blendmode(_blendmode)
	batch_set_filter(_filter)
}