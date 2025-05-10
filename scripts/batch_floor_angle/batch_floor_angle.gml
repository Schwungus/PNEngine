/// @func batch_floor_angle(image, frame, width, height, x, y, z, yaw, pitch, roll, [color], [alpha])
/// @desc Adds a flat angled image to the batch.
/// @param {Struct.__CollageImageClass} image
/// @param {Real} frame
/// @param {Real} width
/// @param {Real} height
/// @param {Real} x
/// @param {Real} y
/// @param {Real} z
/// @param {Real} yaw
/// @param {Real} pitch
/// @param {Real} roll
/// @param {Constant.Color} [color]
/// @param {Real} [alpha]
function batch_floor_angle(_image, _frame, _width, _height, _x, _y, _z, _yaw, _pitch, _roll, _color = c_white, _alpha = 1) {
	var _texture = _image.GetTexture(_frame)
	
	if _texture != global.batch_texture {
		batch_submit()
		global.batch_texture = _texture
	}
	
	var _batch_matrix = matrix_build(_x, _y, _z, _roll, _pitch, _yaw, 1, 1, 1)
	
	var _left = -(_image.GetXOffset() / _image.GetWidth()) * _width
	var _top = (_image.GetYOffset() / _image.GetHeight()) * _height
	var _right = _left + _width
	var _bottom = _top - _height
	
	var _vert1 = matrix_transform_point(_batch_matrix, _left, _top, 0)
	var _x1 = _vert1[0]
	var _y1 = _vert1[1]
	var _z1 = _vert1[2]
	
	var _vert2 = matrix_transform_point(_batch_matrix, _right, _top, 0)
	var _x2 = _vert2[0]
	var _y2 = _vert2[1]
	var _z2 = _vert2[2]
	
	var _vert3 = matrix_transform_point(_batch_matrix, _right, _bottom, 0)
	var _x3 = _vert3[0]
	var _y3 = _vert3[1]
	var _z3 = _vert3[2]
	
	var _vert4 = matrix_transform_point(_batch_matrix, _left, _bottom, 0)
	var _x4 = _vert4[0]
	var _y4 = _vert4[1]
	var _z4 = _vert4[2]
	
	var _u1, _v1, _u2, _v2
	var _uvs = _image.GetUVs(_frame)
	
	with _uvs {
		_u1 = normLeft
		_v1 = normTop
		_u2 = normRight
		_v2 = normBottom
	}
	
	var _batch_vbo = global.batch_vbo
	var _nrm = matrix_build(0, 0, -1, _roll, _pitch, _yaw, 1, 1, 1)
	var _nx = _nrm[12]
	var _ny = _nrm[13]
	var _nz = _nrm[14]
	
	vbo_add_vertex(_batch_vbo, _x1, _y1, _z1, _nx, _ny, _nz, _u2, _v2, _color, _alpha)
	vbo_add_vertex(_batch_vbo, _x2, _y2, _z2, _nx, _ny, _nz, _u1, _v2, _color, _alpha)
	vbo_add_vertex(_batch_vbo, _x3, _y3, _z3, _nx, _ny, _nz, _u1, _v1, _color, _alpha)
	vbo_add_vertex(_batch_vbo, _x1, _y1, _z1, _nx, _ny, _nz, _u2, _v2, _color, _alpha)
	vbo_add_vertex(_batch_vbo, _x3, _y3, _z3, _nx, _ny, _nz, _u1, _v1, _color, _alpha)
	vbo_add_vertex(_batch_vbo, _x4, _y4, _z4, _nx, _ny, _nz, _u2, _v1, _color, _alpha)
}