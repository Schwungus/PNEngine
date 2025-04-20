function Model() : Asset() constructor {
	submodels = undefined
	submodels_amount = 0
	
	root_node = undefined
	nodes_amount = 0
	
	collider = undefined
	
	bone_offsets = undefined
	torso_bone = -1
	hold_bone = -1
	hold_offset_matrix = undefined
	points = undefined
	
	lightmap = undefined
	
	static get_node = function (_id, _node = root_node) {
		var _is_name = is_string(_id)
		
		if _is_name and _node.name == _id {
			return _node
		}
		
		if not _is_name and _node.index == _id {
			return _node
		}
		
		var _children = _node.children
		var i = 0
		
		repeat array_length(_children) {
			var _found = get_node(_id, _children[i++])
			
			if _found != undefined {
				return _found
			}
		}
		
		return undefined
	}
	
	static get_node_id = function (_id) {
		gml_pragma("forceinline")
		
		var _node = get_node(_id)
		
		if _node != undefined {
			return _node.index
		}
		
		return -1
	}
	
	static get_branch = function (_id, _array = []) {
		gml_pragma("forceinline")
		
		var _node = get_node(_id)
		
		if _node != undefined {
			_node.push_branch(_array)
		}
		
		return _array
	}
	
	static get_branch_id = function (_id, _array = []) {
		gml_pragma("forceinline")
		
		var _node = get_node(_id)
		
		if _node != undefined {
			_node.push_branch_id(_array)
		}
		
		return _array
	}
	
	static destroy = function () {
		destroy_array(submodels)
		
		if collider != undefined {
			collider.destroy()
		}
	}
}