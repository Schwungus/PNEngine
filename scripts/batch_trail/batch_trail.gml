/// @func batch_trail(points, [image], [frame], [color1], [color2], [alpha1], [alpha2])
/// @desc Adds a trail to the batch.
///       
///       Each point in the points array consists of the following data:
///       x, y, z, nx, ny, nz, thickness, alpha
///       
///       If the array is not divisible by 8, this function will exit.
/// @param {Array<Real>} points
/// @param {Struct.__CollageImageClass|Real} [image]
/// @param {Real} [frame]
/// @param {Constant.Color} [color1]
/// @param {Constant.Color} [color2]
/// @param {Real} [alpha1]
/// @param {Real} [alpha2]
function batch_trail(_points, _image = -1, _frame = 0, _color1 = c_white, _color2 = c_white, _alpha1 = 1, _alpha2 = 0) {
	var n = array_length(_points) div 8
	
	if n <= 1 {
		exit
	}
	
	var _blank = _image == -1
	var _texture = _blank ? -1 : _image.GetTexture(_frame)
	
	if _texture != global.batch_texture {
		batch_submit()
		global.batch_texture = _texture
	}
	
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
	var i = 0
	
	repeat n - 1 {
		var _p1_x = _points[i]
		var _p1_y = _points[-~i]
		var _p1_z = _points[i + 2]
		var _p1_nx = _points[i + 3]
		var _p1_ny = _points[i + 4]
		var _p1_nz = _points[i + 5]
		var _p1_thickness = _points[i + 6]
		var _p1_alpha = _points[i + 7]
		
		var _p2_x = _points[i + 8]
		var _p2_y = _points[i + 9]
		var _p2_z = _points[i + 10]
		var _p2_nx = _points[i + 11]
		var _p2_ny = _points[i + 12]
		var _p2_nz = _points[i + 13]
		var _p2_thickness = _points[i + 14]
		var _p2_alpha = _points[i + 15]
		
		var _tx1 = _p1_nx * _p1_thickness
		var _ty1 = _p1_ny * _p1_thickness
		var _tz1 = _p1_nz * _p1_thickness
		var _tx2 = _p2_nx * _p2_thickness
		var _ty2 = _p2_ny * _p2_thickness
		var _tz2 = _p2_nz * _p2_thickness
		
		var _x1 = _p1_x + _tx1
		var _y1 = _p1_y + _ty1
		var _z1 = _p1_z + _tz1
		var _x2 = _p1_x - _tx1
		var _y2 = _p1_y - _ty1
		var _z2 = _p1_z - _tz1
		var _x3 = _p2_x - _tx2
		var _y3 = _p2_y - _ty2
		var _z3 = _p2_z - _tz2
		var _x4 = _p2_x + _tx2
		var _y4 = _p2_y + _ty2
		var _z4 = _p2_z + _tz2
		
		vbo_add_vertex(_batch_vbo, _x1, _y1, _z1, 0, 0, -1, _u2, _v1, _color1, _alpha1)
		vbo_add_vertex(_batch_vbo, _x2, _y2, _z2, 0, 0, -1, _u2, _v2, _color2, _alpha2)
		vbo_add_vertex(_batch_vbo, _x3, _y3, _z3, 0, 0, -1, _u1, _v2, _color2, _alpha2)
		vbo_add_vertex(_batch_vbo, _x1, _y1, _z1, 0, 0, -1, _u2, _v1, _color1, _alpha1)
		vbo_add_vertex(_batch_vbo, _x3, _y3, _z3, 0, 0, -1, _u1, _v2, _color2, _alpha2)
		vbo_add_vertex(_batch_vbo, _x4, _y4, _z4, 0, 0, -1, _u1, _v1, _color1, _alpha1)
		vbo_add_vertex(_batch_vbo, _x3, _y3, _z3, 0, 0, -1, _u1, _v2, _color2, _alpha2)
		vbo_add_vertex(_batch_vbo, _x2, _y2, _z2, 0, 0, -1, _u2, _v2, _color2, _alpha2)
		vbo_add_vertex(_batch_vbo, _x1, _y1, _z1, 0, 0, -1, _u2, _v1, _color1, _alpha1)
		vbo_add_vertex(_batch_vbo, _x4, _y4, _z4, 0, 0, -1, _u1, _v1, _color1, _alpha1)
		vbo_add_vertex(_batch_vbo, _x3, _y3, _z3, 0, 0, -1, _u1, _v2, _color2, _alpha2)
		vbo_add_vertex(_batch_vbo, _x1, _y1, _z1, 0, 0, -1, _u2, _v1, _color1, _alpha1)
		i += 8
	}
}