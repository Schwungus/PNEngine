/// @func matrix_world_reset()
function matrix_world_reset() {
	gml_pragma("forceinline")
	
	static _default = matrix_build_identity()
	
	matrix_set(matrix_world, _default)
}