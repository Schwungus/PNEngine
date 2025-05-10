/// @func batch_wall(image, frame, width, height, x, y, z, angle, [color], [alpha])
/// @desc Adds a wall to the batch.
/// @param {Struct.__CollageImageClass|Undefined} image
/// @param {Real} frame
/// @param {Real} width
/// @param {Real} height
/// @param {Real} x
/// @param {Real} y
/// @param {Real} z
/// @param {Real} angle
/// @param {Constant.Color} [color]
/// @param {Real} [alpha]
function batch_wall(_image, _frame, _width, _height, _x, _y, _z, _angle, _color = c_white, _alpha = 1) {
	var _texture = _image.GetTexture(_frame)
	
	if _texture != global.batch_texture {
		batch_submit()
		global.batch_texture = _texture
	}
	
	var _left = -(_image.GetXOffset() / _image.GetWidth()) * _width
	var _top = -(_image.GetYOffset() / _image.GetHeight()) * _height
	var _right = _left + _width
	var _bottom = _top + _height
	
	var _dir = _angle + 90
	
	var _x1 = _x + lengthdir_x(_left, _dir)
	var _y1 = _y + lengthdir_y(_left, _dir)
	var _z1 = _z + _bottom
	
	var _x2 = _x + lengthdir_x(_right, _dir)
	var _y2 = _y + lengthdir_y(_right, _dir)
	var _z2 = _z1
	
	var _x3 = _x2
	var _y3 = _y2
	var _z3 = _z + _top
	
	var _x4 = _x1
	var _y4 = _y1
	var _z4 = _z3
	
	var _u1, _v1, _u2, _v2
	var _uvs = _image.GetUVs(_frame)
	
	with _uvs {
		_u1 = normLeft
		_v1 = normTop
		_u2 = normRight
		_v2 = normBottom
	}
	
	var _batch_vbo = global.batch_vbo
	var _nx = dcos(_angle)
	var _ny = -dsin(_angle)
	
	vbo_add_vertex(_batch_vbo, _x1, _y1, _z1, _nx, _ny, 0, _u2, _v2, _color, _alpha)
	vbo_add_vertex(_batch_vbo, _x2, _y2, _z2, _nx, _ny, 0, _u1, _v2, _color, _alpha)
	vbo_add_vertex(_batch_vbo, _x3, _y3, _z3, _nx, _ny, 0, _u1, _v1, _color, _alpha)
	vbo_add_vertex(_batch_vbo, _x1, _y1, _z1, _nx, _ny, 0, _u2, _v2, _color, _alpha)
	vbo_add_vertex(_batch_vbo, _x3, _y3, _z3, _nx, _ny, 0, _u1, _v1, _color, _alpha)
	vbo_add_vertex(_batch_vbo, _x4, _y4, _z4, _nx, _ny, 0, _u2, _v1, _color, _alpha)
}