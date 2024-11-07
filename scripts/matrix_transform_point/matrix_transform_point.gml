#macro matrix_transform_point matrix_transform_vertex

/*function matrix_transform_point(_matrix, _x, _y, _z) {
	gml_pragma("forceinline")
	
	static _vertex = array_create(3)
	
	_vertex[@ 0] = _matrix[12] + dot_product_3d(_x, _y, _z, _matrix[0], _matrix[4], _matrix[8])
	_vertex[@ 1] = _matrix[13] + dot_product_3d(_x, _y, _z, _matrix[1], _matrix[5], _matrix[9])
	_vertex[@ 2] = _matrix[14] + dot_product_3d(_x, _y, _z, _matrix[2], _matrix[6], _matrix[10])
	
	return _vertex
}*/