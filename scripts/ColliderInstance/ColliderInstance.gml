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
	
	/// @func set_matrix(matrix)
	/// @desc Sets the instance's transform matrix and flags it as dynamic.
	/// @param {Array<Real>} matrix
	/// @return {Bool} Whether or not the matrix is valid.
	/// @context ColliderInstance
	static set_matrix = function (_matrix) {
		var _inverse = matrix_inverse(_matrix)
		
		if _inverse == undefined {
			return false
		}
		
		if not is_static {
			delta_matrix = matrix_multiply(inverse_matrix, _matrix)
		}
		
		inverse_matrix = _inverse
		matrix = _matrix
		is_static = false
		
		return true
	}
	
	/// @func reset_matrix()
	/// @desc Resets the instance's transformation and flags it back to being static.
	/// @context ColliderInstance
	static reset_matrix = function () {
		static _identity = matrix_build_identity()
		
		array_copy(matrix, 0, _identity, 0, 16)
		array_copy(inverse_matrix, 0, _identity, 0, 16)
		array_copy(delta_matrix, 0, _identity, 0, 16)
		is_static = true
	}
#endregion
	
#region Collision
	/// @func raycast(x1, y1, z1, x2, y2, z2, [flags], [layers])
	/// @desc Casts a ray on the instance.
	/// @param {Real} x1 Starting X.
	/// @param {Real} y1 Starting Y.
	/// @param {Real} z1 Starting Z.
	/// @param {Real} x2 Target X.
	/// @param {Real} y2 Target Y.
	/// @param {Real} z2 Target Z.
	/// @param {Real|Enum.CollisionFlags} [flags] Filter for triangles with specific flags.
	/// @param {Real|Enum.CollisionLayers} [layers] Filter for triangles in specific layers.
	/// @return {Array<Any>} Raycast data array. Use "RaycastData" enum or "RAY_*" constants for indices.
	/// @context ColliderInstance
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
								
								// Check if the intersection is inside the
								// triangle.
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
								
								// There is an intersection, apply it for
								// further iterations.
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