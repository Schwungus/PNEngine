/// @func interp(in, out, [angle], [scope])
/// @desc Adds a variable to interpolate.
/// @param {String} in Input variable name.
/// @param {String} out Output variable name.
/// @param {Bool} [angle] Whether or not to consider the variable an angle.
/// @param {Struct|Id.Instance} [scope] The scope to assign the output variable to.
function interp(_in, _out, _angle = false, _scope = undefined) {
	static __interp_hash = variable_get_hash("__interp")
	
	_scope ??= self
	
	var _data = struct_get_from_hash(_scope, __interp_hash)
	
	if _data == undefined {
		var _interps = global.interps
		var _id = ds_list_find_index(_interps, undefined)
		
		if _id == -1 {
			_id = ds_list_size(_interps)
		}
		
		var _weak_ref
		
		if instance_exists(_scope) and struct_exists(_scope, "id") {
			_weak_ref = _scope.id
		} else if is_struct(_scope) {
			_weak_ref = weak_ref_create(_scope)
		} else {
			show_error($"!!! interp: Invalid scope, got {typeof(_scope)}", true)
		}
		
		_interps[| _id] = _weak_ref
		_data = []
		struct_set_from_hash(_scope, __interp_hash, _data)
	}
	
	var _in_hash = variable_get_hash(_in)
	var _out_hash = variable_get_hash(_out)
	var _value = struct_get_from_hash(_scope, _in_hash)
	
	struct_set_from_hash(_scope, _out_hash, _value)
	array_push(_data, [_in, _out, _in_hash, _out_hash, _value, _angle])
}