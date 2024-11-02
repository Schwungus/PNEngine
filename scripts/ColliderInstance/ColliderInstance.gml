function ColliderInstance(_collider) constructor {
	collider = _collider
	triangles = _collider.triangles
	regions = _collider.regions
	grid = _collider.grid
	x1 = _collider.x1
	y1 = _collider.y1
	x2 = _collider.x2
	y2 = _collider.y2
	layer_mask = _collider.layer_mask
	
#region Matrices
	matrix = matrix_build_identity()
	inverse_matrix = matrix_build_identity()
	delta_matrix = matrix_build_identity()
	is_static = true
	
	static set_matrix = function (_matrix) {
		var m0 = _matrix[0]
		var m1 = _matrix[1]
		var m2 = _matrix[2]
		var m4 = _matrix[4]
		var m5 = _matrix[5]
		var m6 = _matrix[6]
		var m8 = _matrix[8]
		var m9 = _matrix[9]
		var m10 = _matrix[10]
		
		var i0 = m5 * m10 - m9 * m6
		var i4 = m8 * m6  - m4 * m10
		var i8 = m4 * m9  - m8 * m5
		
		var d = dot_product_3d(m0, m1, m2, i0, i4, i8)
		
		if d == 0 {
			return false
		}
		
		if not is_static {
			delta_matrix = matrix_multiply(inverse_matrix, _matrix)
		}
		
		var m12 = _matrix[12]
		var m13 = _matrix[13]
		var m14 = _matrix[14]
		
		var i1 = m9 * m2  - m1 * m10
		var i2 = m1 * m6  - m5 * m2
		var i5 = m0 * m10 - m8 * m2
		var i6 = m4 * m2  - m0 * m6
		var i9 = m8 * m1  - m0 * m9
		var i10 = m0 * m5  - m4 * m1
		
		inverse_matrix[0] = i0
		inverse_matrix[1] = i1
		inverse_matrix[2] = i2
		inverse_matrix[4] = i4
		inverse_matrix[5] = i5
		inverse_matrix[6] = i6
		inverse_matrix[8] = i8
		inverse_matrix[9] = i9
		inverse_matrix[10] = i10
		inverse_matrix[12] = -dot_product_3d(m12, m13, m14, i0, i4, i8)
		inverse_matrix[13] = -dot_product_3d(m12, m13, m14, i1, i5, i9)
		inverse_matrix[14] = -dot_product_3d(m12, m13, m14, i2, i6, i10)
		inverse_matrix[15] = m0 * m5 * m10 - m0 * m6 * m9 - m4 * m1 * m10 + m4 * m2 * m9 + m8 * m1 * m6 - m8 * m2 * m5
		
		d = 1 / d
		
		var i = 0
		
		repeat 16 {
			inverse_matrix[i++] *= d
		}
		
		matrix = _matrix
		is_static = false
		
		return true
	}
	
	static reset_matrix = function () {
		static _identity = matrix_build_identity()
		
		array_copy(matrix, 0, _identity, 0, 16)
		array_copy(inverse_matrix, 0, _identity, 0, 16)
		array_copy(delta_matrix, 0, _identity, 0, 16)
		is_static = true
	}
#endregion
	
#region Collision
	static raycast = function (_x1, _y1, _z1, _x2, _y2, _z2, _flags = CollisionFlags.ALL, _layers = CollisionLayers.ALL) {
		static _result = raycast_data_create()
		
		var _hit = false
		var _nx = 0
		var _ny = 0
		var _nz = 1
		var _surface = 0
		var _hit_triangle = undefined
		
		if _layers != 0 and layer_mask != 0 {
			if not is_static {
				var _start = matrix_transform_point(inverse_matrix, _x1, _y1, _z1)
				
				_x1 = _start[0]
				_y1 = _start[1]
				_z1 = _start[2]
				
				var _end = matrix_transform_point(inverse_matrix, _x2, _y2, _z2)
				
				_x2 = _end[0]
				_y2 = _end[1]
				_z2 = _end[2]
			}
			
			if line_in_rectangle(_x1, _y1, _x2, _y2, x1, y1, x2, y2) {
				// Iterate through every region overlapped by the ray
				var _width = ds_grid_width(grid)
				var _height = ds_grid_height(grid)
				
				// Line coordinates in grid
				var _lx1 = floor((_x1 - x1) * COLLIDER_REGION_SIZE_INVERSE)
				var _ly1 = floor((_y1 - y1) * COLLIDER_REGION_SIZE_INVERSE)
				var _lx2 = floor((_x2 - x1) * COLLIDER_REGION_SIZE_INVERSE)
				var _ly2 = floor((_y2 - y1) * COLLIDER_REGION_SIZE_INVERSE)
				
				// Distance between (lx1, ly1) and (lx2, ly2)
				var _dx = abs(_lx2 - _lx1)
				var _dy = abs(_ly2 - _ly1)
				
				// Current position
				var _x = _lx1
				var _y = _ly1
				
				// Iteration
				var _x_step = _lx2 > _lx1 ? 1 : -1
				var _y_step = _ly2 > _ly1 ? 1 : -1
				var _error = _dx - _dy
				
				_dx *= 2
				_dy *= 2
				
				repeat 1 + _dx + _dy {
					if _x >= 0 and _x < _width and _y >= 0 and _y < _height {
						var _region = grid[# _x, _y]
						
						if _region != -1 {
							var i = 0
							
							repeat ds_list_size(_region) {
								// Check this triangle for an intersection.
								var _triangle = _region[| i++]
								
								// Skip if this triangle does not match our
								// flags.
								if not (_triangle[TriangleData.FLAGS] & _flags) {
									continue
								}
								
								var _tl = _triangle[TriangleData.LAYERS]
								
								// Skip if this triangle does not match our
								// layers.
								if (not (_tl & _layers)) or (not (_tl & layer_mask)) {
									continue
								}
								
								var _tnx = _triangle[9]
								var _tny = _triangle[10]
								var _tnz = _triangle[11]
								
								// Find the intersection between the ray
								// and the triangle's plane.
								var _dot = dot_product_3d(_tnx, _tny, _tnz, _x2 - _x1, _y2 - _y1, _z2 - _z1)
								
								if _dot == 0 {
									continue
								}
								
								var _tx1 = _triangle[0]
								var _ty1 = _triangle[1]
								var _tz1 = _triangle[2]
								
								_dot = dot_product_3d(_tnx, _tny, _tnz, _tx1 - _x1, _ty1 - _y1, _tz1 - _z1) / _dot
								
								if _dot < 0 or _dot > 1 {
									continue
								}
								
								var _ix = lerp(_x1, _x2, _dot)
								var _iy = lerp(_y1, _y2, _dot)
								var _iz = lerp(_z1, _z2, _dot)
								
								// Check if the intersection is inside the triangle.
								var _tx2 = _triangle[3]
								var _ty2 = _triangle[4]
								var _tz2 = _triangle[5]
								
								var _ax = _ix - _tx1
								var _ay = _iy - _ty1
								var _az = _iz - _tz1
								var _bx = _tx2 - _tx1
								var _by = _ty2 - _ty1
								var _bz = _tz2 - _tz1
								
								if dot_product_3d(_tnx, _tny, _tnz, _az * _by - _ay * _bz, _ax * _bz - _az * _bx, _ay * _bx - _ax * _by) < 0 {
									continue
								}
								
								var _tx3 = _triangle[6]
								var _ty3 = _triangle[7]
								var _tz3 = _triangle[8]
								
								_ax = _ix - _tx2
								_ay = _iy - _ty2
								_az = _iz - _tz2
								_bx = _tx3 - _tx2
								_by = _ty3 - _ty2
								_bz = _tz3 - _tz2
								
								if dot_product_3d(_tnx, _tny, _tnz, _az * _by - _ay * _bz, _ax * _bz - _az * _bx, _ay * _bx - _ax * _by) < 0 {
									continue
								}
								
								_ax = _ix - _tx3
								_ay = _iy - _ty3
								_az = _iz - _tz3
								_bx = _tx1 - _tx3
								_by = _ty1 - _ty3
								_bz = _tz1 - _tz3
								
								if dot_product_3d(_tnx, _tny, _tnz, _az * _by - _ay * _bz, _ax * _bz - _az * _bx, _ay * _bx - _ax * _by) < 0 {
									continue
								}
								
								// There is an intersection, apply it for further iterations.
								_hit = true
								_x2 = _ix
								_y2 = _iy
								_z2 = _iz
								_nx = _tnx
								_ny = _tny
								_nz = _tnz
								_surface = _triangle[TriangleData.SURFACE]
								_hit_triangle = _triangle
							}
							
							if _hit {
								break
							}
						}
					}
					
					if _error > 0 {
						_x += _x_step
						_error -= _dy
					} else {
						_y += _y_step
						_error += _dx
					}
				}
			}
			
			if not is_static {
				var _end = matrix_transform_point(matrix, _x2, _y2, _z2)
				
				_x2 = _end[0]
				_y2 = _end[1]
				_z2 = _end[2]
				_end = matrix_transform_vertex(matrix, _nx, _ny, _nz, 0)
				_nx = _end[0]
				_ny = _end[1]
				_nz = _end[2]
				
				var d = 1 / point_distance_3d(0, 0, 0, _nx, _ny, _nz)
				
				_nx *= d
				_ny *= d
				_nz *= d
			}
		}
		
		_result[RaycastData.HIT] = _hit
		_result[RaycastData.X] = _x2
		_result[RaycastData.Y] = _y2
		_result[RaycastData.Z] = _z2
		_result[RaycastData.NX] = _nx
		_result[RaycastData.NY] = _ny
		_result[RaycastData.NZ] = _nz
		_result[RaycastData.SURFACE] = _surface
		_result[RaycastData.TRIANGLE] = _hit_triangle
		
		return _result
	}
#endregion
}