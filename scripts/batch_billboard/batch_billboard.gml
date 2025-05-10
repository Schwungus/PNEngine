/// @func batch_billboard(image, frame, width, height, x, y, z, [angle], [color], [alpha])
/// @desc Adds a X/Y billboard image that faces the camera to the batch.
/// @param {Struct.__CollageImageClass|Real} image
/// @param {Real} frame
/// @param {Real} width
/// @param {Real} height
/// @param {Real} x
/// @param {Real} y
/// @param {Real} z
/// @param {Real} [angle]
/// @param {Constant.Color} [color]
/// @param {Real} [alpha]
function batch_billboard(_image, _frame, _width, _height, _x, _y, _z, _angle = 0, _color = c_white, _alpha = 1) {
	var _blank = _image == -1
	var _texture = _blank ? -1 : _image.GetTexture(_frame)
	
	if _texture != global.batch_texture {
		batch_submit()
		global.batch_texture = _texture
	}
	
	var _x_offset, _y_offset
	
	if _blank {
		_x_offset = 0
		_y_offset = 0
	} else {
		_x_offset = (_image.GetXOffset() / _image.GetWidth()) * _width
		_y_offset = (_image.GetYOffset() / _image.GetHeight()) * _height
	}
	
	var _camera = global.batch_camera
	var _yaw = _camera.syaw + 180
	var _pitch = -_camera.spitch
	
	var _matrix = matrix_multiply(
		matrix_multiply(
			matrix_build(0, (_width * -0.5) + _x_offset, (_height * 0.5) - _y_offset, 0, 0, 0, _width, _width, _height),
			matrix_build(0, 0, 0, _angle, 0, 0, 1, 1, 1)
		),
		
		matrix_build(_x, _y, _z, 0, _pitch, _yaw, 1, 1, 1)
	)
	
	var _vert1 = matrix_transform_point(_matrix, 0, 0.5, -0.5)
	var _x1 = _vert1[0]
	var _y1 = _vert1[1]
	var _z1 = _vert1[2]
	
	var _vert2 = matrix_transform_point(_matrix, 0, 0.5, 0.5)
	var _x2 = _vert2[0]
	var _y2 = _vert2[1]
	var _z2 = _vert2[2]
	
	var _vert3 = matrix_transform_point(_matrix, 0, -0.5, 0.5)
	var _x3 = _vert3[0]
	var _y3 = _vert3[1]
	var _z3 = _vert3[2]
	
	var _vert4 = matrix_transform_point(_matrix, 0, -0.5, -0.5)
	var _x4 = _vert4[0]
	var _y4 = _vert4[1]
	var _z4 = _vert4[2]
	
	var _u1, _v1, _u2, _v2
	
	if _blank {
		_u1 = 0
		_v1 = 0
		_u2 = 1
		_v2 = 1
	} else {
		var _uvs = _image.GetUVs(_frame)
		
		with _uvs {
			_u1 = normLeft
			_v1 = normTop
			_u2 = normRight
			_v2 = normBottom
		}
	}
	
	var _batch_vbo = global.batch_vbo
	
	vbo_add_vertex(_batch_vbo, _x1, _y1, _z1, 0, 0, -1, _u2, _v1, _color, _alpha)
	vbo_add_vertex(_batch_vbo, _x2, _y2, _z2, 0, 0, -1, _u2, _v2, _color, _alpha)
	vbo_add_vertex(_batch_vbo, _x3, _y3, _z3, 0, 0, -1, _u1, _v2, _color, _alpha)
	vbo_add_vertex(_batch_vbo, _x1, _y1, _z1, 0, 0, -1, _u2, _v1, _color, _alpha)
	vbo_add_vertex(_batch_vbo, _x3, _y3, _z3, 0, 0, -1, _u1, _v2, _color, _alpha)
	vbo_add_vertex(_batch_vbo, _x4, _y4, _z4, 0, 0, -1, _u1, _v1, _color, _alpha)
}