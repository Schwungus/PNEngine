/// @func matrix_build_normal(x, y, z, nx, ny, nz, scale, [matrix])
/// @param {Real} x
/// @param {Real} y
/// @param {Real} z
/// @param {Real} nx
/// @param {Real} ny
/// @param {Real} nz
/// @param {Real} scale
/// @param {Array<Real>} [matrix]
/// @return {Array<Real>}
function matrix_build_normal(_x, _y, _z, _nx, _ny, _nz, _scale, _matrix = matrix_build_identity()) {
	// Normalize the input normal
	var l = sqr(_nx) + sqr(_ny) + sqr(_nz)
	
	if l > 0 and l < 1 {
		l = 1 / sqrt(l)
		_nx *= l
		_ny *= l 
		_nz *= l
	}
	
	// Orthogonalize x-axis to the normal
	var _xx = 1 - _nx * _nx
	var _xy = -_ny * _nx
	var _xz = -_nz * _nx
	
	l = sqr(_xx) + sqr(_xy) + sqr(_xz)
	
	if l > 0 and l < 1 {
		l = 1 / sqrt(l)
		_xx *= l
		_xy *= l 
		_xz *= l
	}
	
	// Orthogonalize y-axis to the normal
	var _yx = -_nx * _ny
	var _yy = 1 - _ny * _ny
	var _yz = -_nz * _ny
	
	l = sqr(_yx) + sqr(_yy) + sqr(_yz)
	
	if l > 0 and l < 1 {
		l = 1 / sqrt(l)
		_yx *= l
		_yy *= l
		_yz *= l
	}
	
	// Construct matrix
	_matrix[0] = _xx * _scale
	_matrix[1] = _xy * _scale
	_matrix[2] = _xz * _scale
	
	_matrix[4] = _yx * _scale
	_matrix[5] = _yy * _scale
	_matrix[6] = _yz * _scale
	
	_matrix[8] = _nx * _scale
	_matrix[9] = _ny * _scale
	_matrix[10] = _nz * _scale
	
	_matrix[12] = _x
	_matrix[13] = _y
	_matrix[14] = _z
	_matrix[15] = 1
	
	return _matrix
}