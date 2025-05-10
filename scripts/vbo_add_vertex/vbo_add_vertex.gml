/// @param {Id.VertexBuffer} vbo
/// @param {Real} x
/// @param {Real} y
/// @param {Real} z
/// @param {Real} nx
/// @param {Real} ny
/// @param {Real} nz
/// @param {Real} u
/// @param {Real} v
/// @param {Constant.Color} color
/// @param {Real} alpha
function vbo_add_vertex(_vbo, _x, _y, _z, _nx, _ny, _nz, _u, _v, _color, _alpha) {
	gml_pragma("forceinline")
	
	vertex_position_3d(_vbo, _x, _y, _z)
	vertex_normal(_vbo, _nx, _ny, _nz)
	vertex_texcoord(_vbo, _u, _v)
	vertex_texcoord(_vbo, 0, 0)
	vertex_color(_vbo, _color, _alpha)
	vertex_float4(_vbo, 0, 0, 0, 0)
	vertex_float4(_vbo, 0, 0, 0, 0)
}