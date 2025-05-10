/// @param {Any} value
/// @param {String} type
/// @param {Any} fallback
/// @return {Any}
function force_type_fallback(_value, _type, _fallback = undefined) {
	gml_pragma("forceinline")
	
	if typeof(_value) != _type {
		return _fallback
	}
	
	return _value
}