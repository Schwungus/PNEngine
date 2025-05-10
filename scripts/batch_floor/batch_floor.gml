/// @func batch_floor(image, frame, width, height, x, y, z, [color], [alpha])
/// @desc Adds a flat image to the batch.
/// @param {Struct.__CollageImageClass} image
/// @param {Real} frame
/// @param {Real} width
/// @param {Real} height
/// @param {Real} x
/// @param {Real} y
/// @param {Real} z
/// @param {Constant.Color} [color]
/// @param {Real} [alpha]
function batch_floor(_image, _frame, _width, _height, _x, _y, _z, _color = c_white, _alpha = 1) {
	var _texture = _image.GetTexture(_frame)
	
	if _texture != global.batch_texture {
		batch_submit()
		global.batch_texture = _texture
	}
	
	var _x1 = _x - (_image.GetXOffset() / _image.GetWidth()) * _width
	var _y1 = _y + (_image.GetYOffset() / _image.GetHeight()) * _height
	var _x2 = _x1 + _width
	var _y2 = _y1 - _height
	
	var _u1, _v1, _u2, _v2
	var _uvs = _image.GetUVs(_frame)
	
	with _uvs {
		_u1 = normLeft
		_v1 = normTop
		_u2 = normRight
		_v2 = normBottom
	}
	
	var _batch_vbo = global.batch_vbo
	
	vbo_add_vertex(_batch_vbo, _x2, _y2, _z, 0, 0, -1, _u2, _v2, _color, _alpha)
	vbo_add_vertex(_batch_vbo, _x1, _y2, _z, 0, 0, -1, _u1, _v2, _color, _alpha)
	vbo_add_vertex(_batch_vbo, _x1, _y1, _z, 0, 0, -1, _u1, _v1, _color, _alpha)
	vbo_add_vertex(_batch_vbo, _x2, _y2, _z, 0, 0, -1, _u2, _v2, _color, _alpha)
	vbo_add_vertex(_batch_vbo, _x1, _y1, _z, 0, 0, -1, _u1, _v1, _color, _alpha)
	vbo_add_vertex(_batch_vbo, _x2, _y1, _z, 0, 0, -1, _u2, _v1, _color, _alpha)
}