/// @func cross_product_3d(x1, y1, z1, x2, y2, z2)
/// @param {Real} x1
/// @param {Real} y1
/// @param {Real} z1
/// @param {Real} x2
/// @param {Real} y2
/// @param {Real} z2
/// @return {Array<Real>}
function cross_product_3d(_x1, _y1, _z1, _x2, _y2, _z2) {
	gml_pragma("forceinline")
	
	static result = array_create(3)
	
	result[0] = (_y1 * _z2) - (_z1 * _y2)
	result[1] = (_z1 * _x2) - (_x1 * _z2)
	result[2] = (_x1 * _y2) - (_y1 * _x2)
	
	return result
}