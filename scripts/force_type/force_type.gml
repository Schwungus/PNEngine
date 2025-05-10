/// @param {Any} value
/// @param {String} type
/// @return {Any}
function force_type(_value, _type) {
	gml_pragma("forceinline")
	
	var _typeof = typeof(_value)
	
	if typeof(_value) != _type {
		show_error($"!!! force_type: Expected {_type}, got {_typeof}", true)
	}
	
	return _value
}