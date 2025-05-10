/// @func dq_multiply(dq1, dq2, [out])
/// @param {Array<Real>} dq1
/// @param {Array<Real>} dq2
/// @param {Array<Real>} [out]
/// @return {Array<Real>}
function dq_multiply(_dq1, _dq2, _dq = dq_build_identity()) {
	gml_pragma("forceinline")
	
	var _dq1_rx = _dq1[0]
	var _dq1_ry = _dq1[1]
	var _dq1_rz = _dq1[2]
	var _dq1_rw = _dq1[3]
	var _dq1_dx = _dq1[4]
	var _dq1_dy = _dq1[5]
	var _dq1_dz = _dq1[6]
	var _dq1_dw = _dq1[7]
	
	var _dq2_rx = _dq2[0]
	var _dq2_ry = _dq2[1]
	var _dq2_rz = _dq2[2]
	var _dq2_rw = _dq2[3]
	var _dq2_dx = _dq2[4]
	var _dq2_dy = _dq2[5]
	var _dq2_dz = _dq2[6]
	var _dq2_dw = _dq2[7]
	
	_dq[0] = _dq1_rw * _dq2_rx + _dq1_rx * _dq2_rw + _dq1_ry * _dq2_rz - _dq1_rz * _dq2_ry
	_dq[1] = _dq1_rw * _dq2_ry + _dq1_ry * _dq2_rw + _dq1_rz * _dq2_rx - _dq1_rx * _dq2_rz
	_dq[2] = _dq1_rw * _dq2_rz + _dq1_rz * _dq2_rw + _dq1_rx * _dq2_ry - _dq1_ry * _dq2_rx
	_dq[3] = _dq1_rw * _dq2_rw - _dq1_rx * _dq2_rx - _dq1_ry * _dq2_ry - _dq1_rz * _dq2_rz
	_dq[4] = _dq1_rw * _dq2_dx + _dq1_rx * _dq2_dw + _dq1_ry * _dq2_dz - _dq1_rz * _dq2_dy + _dq1_dw * _dq2_rx + _dq1_dx * _dq2_rw + _dq1_dy * _dq2_rz - _dq1_dz * _dq2_ry
	_dq[5] = _dq1_rw * _dq2_dy + _dq1_ry * _dq2_dw + _dq1_rz * _dq2_dx - _dq1_rx * _dq2_dz + _dq1_dw * _dq2_ry + _dq1_dy * _dq2_rw + _dq1_dz * _dq2_rx - _dq1_dx * _dq2_rz
	_dq[6] = _dq1_rw * _dq2_dz + _dq1_rz * _dq2_dw + _dq1_rx * _dq2_dy - _dq1_ry * _dq2_dx + _dq1_dw * _dq2_rz + _dq1_dz * _dq2_rw + _dq1_dx * _dq2_ry - _dq1_dy * _dq2_rx
	_dq[7] = _dq1_rw * _dq2_dw - _dq1_rx * _dq2_dx - _dq1_ry * _dq2_dy - _dq1_rz * _dq2_dz + _dq1_dw * _dq2_rw - _dq1_dx * _dq2_rx - _dq1_dy * _dq2_ry - _dq1_dz * _dq2_rz
	
	return _dq
}