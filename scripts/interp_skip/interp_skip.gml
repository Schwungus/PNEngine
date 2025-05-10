/// @func interp_skip(out, [scope])
/// @desc Snaps the interpolated variable to its target value.
/// @param {String} out Output variable name.
/// @param {Struct|Id.Instance} [scope] Interpolation scope.
/// @return {Bool} Whether or not the skip was successful.
function interp_skip(_out, _scope = undefined) {
	static __interp_hash = variable_get_hash("__interp")
	
	_scope ??= self
	
	var _interp = struct_get_from_hash(_scope, __interp_hash)
	
	if _interp == undefined {
		return false
	}
	
	var i = 0
	
	repeat array_length(_interp) {
		var _child = _interp[i++]
		
		if _child[InterpData.OUT] == _out {
			var _in = struct_get_from_hash(_scope, _child[InterpData.IN_HASH])
			
			_child[InterpData.PREVIOUS_VALUE] = _in
			struct_set_from_hash(_scope, _child[InterpData.OUT_HASH], _in)
			
			return true
		}
	}
	
	return false
}