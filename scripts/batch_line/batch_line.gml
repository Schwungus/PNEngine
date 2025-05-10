/// @func batch_line(image, frame, x1, y1, z1, x2, y2, z2, radius, [color], [alpha])
/// @desc Adds a textured line to the batch.
/// @param {Struct.__CollageImageClass|Real} image
/// @param {Real} frame
/// @param {Real} x1
/// @param {Real} y1
/// @param {Real} z1
/// @param {Real} x2
/// @param {Real} y2
/// @param {Real} z2
/// @param {Real} radius
/// @param {Constant.Color} [color]
/// @param {Real} [alpha]
function batch_line(_image, _frame, _x1, _y1, _z1, _x2, _y2, _z2, _radius, _color = c_white, _alpha = 1) {
	var _blank = _image == -1
	var _texture = _blank ? -1 : _image.GetTexture(_frame)
	
	if _texture != global.batch_texture {
		batch_submit()
		global.batch_texture = _texture
	}
	
	var _cx, _cy, _cz
	
	with global.batch_camera {
		_cx = sx
		_cy = sy
		_cz = sz
	}
	
	/* In order to make the line always face the camera (DOESN'T WORK BTW):
	var _cross = cross_product_3d_normalized(lerp(_x1, _x2, 0.5), lerp(_y1, _y2, 0.5), lerp(_z1, _z2, 0.5), _cx, _cy, _cz)
	var _lx = _cross[0] * _radius
	var _ly = _cross[1] * _radius
	var _lz = _cross[2] * _radius
	
	var __x1 = _x1 + _lx 
	var __y1 = _y1 + _ly
	var __z1 = _z1 + _lz
	
	var __x2 = _x1 - _lx
	var __y2 = _y1 - _ly
	var __z2 = _z1 - _lz
	
	var __x3 = _x2 - _lx
	var __y3 = _y2 - _ly
	var __z3 = _z2 - _lz
	
	var __x4 = _x2 + _lx
	var __y4 = _y2 + _ly
	var __z4 = _z2 + _lz */
	
	var _dir = point_direction(_x1, _y1, _x2, _y2)
	var _left = _dir - 90
	var _right = _dir + 90
	
	var _lx = lengthdir_x(_radius, _left)
	var _ly = lengthdir_y(_radius, _left)
	var _rx = lengthdir_x(_radius, _right)
	var _ry = lengthdir_y(_radius, _right)
	
	// Bottom left
	var __x1 = _x1 + _rx
	var __y1 = _y1 + _ry
	var __z1 = _z1
	
	// Bottom right
	var __x2 = _x2 + _rx
	var __y2 = _y2 + _ry
	var __z2 = _z2
	
	// Top right
	var __x3 = _x2 + _lx
	var __y3 = _y2 + _ly
	var __z3 = _z2
	
	// Top left
	var __x4 = _x1 + _lx
	var __y4 = _y1 + _ly
	var __z4 = _z1
	
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
	
	vbo_add_vertex(_batch_vbo, __x1, __y1, __z1, 0, 0, -1, _u1, _v2, _color, _alpha)
	vbo_add_vertex(_batch_vbo, __x2, __y2, __z2, 0, 0, -1, _u2, _v2, _color, _alpha)
	vbo_add_vertex(_batch_vbo, __x3, __y3, __z3, 0, 0, -1, _u2, _v1, _color, _alpha)
	vbo_add_vertex(_batch_vbo, __x1, __y1, __z1, 0, 0, -1, _u1, _v2, _color, _alpha)
	vbo_add_vertex(_batch_vbo, __x3, __y3, __z3, 0, 0, -1, _u2, _v1, _color, _alpha)
	vbo_add_vertex(_batch_vbo, __x4, __y4, __z4, 0, 0, -1, _u1, _v1, _color, _alpha)
	
	vbo_add_vertex(_batch_vbo, __x4, __y4, __z4, 0, 0, -1, _u1, _v1, _color, _alpha)
	vbo_add_vertex(_batch_vbo, __x3, __y3, __z3, 0, 0, -1, _u2, _v1, _color, _alpha)
	vbo_add_vertex(_batch_vbo, __x1, __y1, __z1, 0, 0, -1, _u1, _v2, _color, _alpha)
	vbo_add_vertex(_batch_vbo, __x3, __y3, __z3, 0, 0, -1, _u2, _v1, _color, _alpha)
	vbo_add_vertex(_batch_vbo, __x2, __y2, __z2, 0, 0, -1, _u2, _v2, _color, _alpha)
	vbo_add_vertex(_batch_vbo, __x1, __y1, __z1, 0, 0, -1, _u1, _v2, _color, _alpha)
}