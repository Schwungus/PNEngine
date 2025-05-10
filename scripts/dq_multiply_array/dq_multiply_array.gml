/// @func dq_multiply_array(dq1, dq1_index, dq2, dq2_index, dest, dest_index)
/// @param {Array<Real>} dq1
/// @param {Real} dq1_index
/// @param {Array<Real>} dq2
/// @param {Real} dq2_index
/// @param {Array<Real>} dest
/// @param {Real} dest_index
function dq_multiply_array(_dq1, _dq1_index, _dq2, _dq2_index, _dest, _dest_index) {
	gml_pragma("forceinline")

	var _dq1r0 = _dq1[_dq1_index]
	var _dq1r1 = _dq1[-~_dq1_index]
	var _dq1r2 = _dq1[_dq1_index + 2]
	var _dq1r3 = _dq1[_dq1_index + 3]
	var _dq1d0 = _dq1[_dq1_index + 4]
	var _dq1d1 = _dq1[_dq1_index + 5]
	var _dq1d2 = _dq1[_dq1_index + 6]
	var _dq1d3 = _dq1[_dq1_index + 7]
	var _dq2r0 = _dq2[_dq2_index + 0]
	var _dq2r1 = _dq2[_dq2_index + 1]
	var _dq2r2 = _dq2[_dq2_index + 2]
	var _dq2r3 = _dq2[_dq2_index + 3]
	var _dq2d0 = _dq2[_dq2_index + 4]
	var _dq2d1 = _dq2[_dq2_index + 5]
	var _dq2d2 = _dq2[_dq2_index + 6]
	var _dq2d3 = _dq2[_dq2_index + 7]
	
	_dest[_dest_index] = (_dq2r3 * _dq1r0 + _dq2r0 * _dq1r3 + _dq2r1 * _dq1r2 - _dq2r2 * _dq1r1)
	_dest[-~_dest_index] = (_dq2r3 * _dq1r1 + _dq2r1 * _dq1r3 + _dq2r2 * _dq1r0 - _dq2r0 * _dq1r2)
	_dest[_dest_index + 2] = (_dq2r3 * _dq1r2 + _dq2r2 * _dq1r3 + _dq2r0 * _dq1r1 - _dq2r1 * _dq1r0)
	_dest[_dest_index + 3] = (_dq2r3 * _dq1r3 - _dq2r0 * _dq1r0 - _dq2r1 * _dq1r1 - _dq2r2 * _dq1r2)
	_dest[_dest_index + 4] = (_dq2d3 * _dq1r0 + _dq2d0 * _dq1r3 + _dq2d1 * _dq1r2 - _dq2d2 * _dq1r1) + (_dq2r3 * _dq1d0 + _dq2r0 * _dq1d3 + _dq2r1 * _dq1d2 - _dq2r2 * _dq1d1)
	_dest[_dest_index + 5] = (_dq2d3 * _dq1r1 + _dq2d1 * _dq1r3 + _dq2d2 * _dq1r0 - _dq2d0 * _dq1r2) + (_dq2r3 * _dq1d1 + _dq2r1 * _dq1d3 + _dq2r2 * _dq1d0 - _dq2r0 * _dq1d2)
	_dest[_dest_index + 6] = (_dq2d3 * _dq1r2 + _dq2d2 * _dq1r3 + _dq2d0 * _dq1r1 - _dq2d1 * _dq1r0) + (_dq2r3 * _dq1d2 + _dq2r2 * _dq1d3 + _dq2r0 * _dq1d1 - _dq2r1 * _dq1d0)
	_dest[_dest_index + 7] = (_dq2d3 * _dq1r3 - _dq2d0 * _dq1r0 - _dq2d1 * _dq1r1 - _dq2d2 * _dq1r2) + (_dq2r3 * _dq1d3 - _dq2r0 * _dq1d0 - _dq2r1 * _dq1d1 - _dq2r2 * _dq1d2)
}