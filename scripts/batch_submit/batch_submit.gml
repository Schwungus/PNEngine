/// @desc Submits the current batch, creating a new one.
function batch_submit() {
	var _batch_texture = global.batch_texture
	
	if _batch_texture == undefined {
		// Abort if the batch is completely empty
		return false
	}
	
	global.u_animated.set(0)
	global.u_color.set(1, 1, 1, 1)
	global.u_stencil.set(1, 1, 1, 0)
	global.u_material_alpha_test.set(global.batch_alpha_test)
	global.u_material_bright.set(global.batch_bright)
	global.u_material_color.set(1, 1, 1, 1)
	global.u_material_scroll.set(0, 0)
	global.u_material_specular.set(0, 1, 0, 1)
	global.u_material_half_lambert.set(1)
	global.u_material_cel.set(0)
	global.u_material_wind.set(0, 1, 1)
	global.u_material_can_blend.set(0)
	global.u_uvs.set(0, 0, 1, 1)
	global.u_texture_size.set(texture_get_width(_batch_texture), texture_get_height(_batch_texture))
	global.u_max_lod.set(0)
	global.u_mipmaps.set(global.blank_mipmap)
	
	var _matrix = matrix_get(matrix_world)
	var _blend_mode = gpu_get_blendmode()
	var _tex_filter = gpu_get_tex_filter()
	var _batch_vbo = global.batch_vbo
	
	matrix_world_reset()
	gpu_set_blendmode(global.batch_blendmode)
	gpu_set_tex_filter(_tex_filter * global.batch_filter)
	vertex_end(_batch_vbo)
	vertex_submit(_batch_vbo, pr_trianglelist, _batch_texture)
	gpu_set_tex_filter(_tex_filter)
	gpu_set_blendmode(_blend_mode)
	matrix_set(matrix_world, _matrix)
	
	vertex_delete_buffer(_batch_vbo)
	_batch_vbo = vertex_create_buffer()
	vertex_begin(_batch_vbo, global.vbo_format)
	global.batch_vbo = _batch_vbo
	global.batch_texture = undefined
	
	return true
}