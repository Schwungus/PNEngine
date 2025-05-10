/// @func dq_build_identity()
/// @desc Creates a dual quaternion without any transformations.
/// @return {Array<Real>}
function dq_build_identity() {
	gml_pragma("forceinline")
	
	return [0, 0, 0, 1, 0, 0, 0, 0]
}