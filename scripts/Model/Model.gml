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
	
	/// @func get_node(name_or_id, [node])
	/// @desc Searches for a Node from a starting node and returns it.
	/// @param {String|Real} name_or_id Node name or ID.
	/// @param {Struct.Node} [node] Node to start searching from.
	/// @return {Struct.Node|Undefined}
	/// @context Model
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
	
	/// @func get_node_id(name_or_id)
	/// @desc Searches for a Node and returns its ID.
	/// @param {String|Real} name_or_id Node name or ID.
	/// @return {Real} Node ID (-1 if not found).
	/// @context Model
	static get_node_id = function (_id) {
		gml_pragma("forceinline")
		
		var _node = get_node(_id)
		
		if _node != undefined {
			return _node.index
		}
		
		return -1
	}
	
	/// @func get_branch(name_or_id, [array])
	/// @desc Searches for a Node and pushes its branch into an array.
	/// @param {String|Real} name_or_id Node name or ID.
	/// @param {Array} [array] Array to push Nodes into.
	/// @return {Array} An array containing the Node and its children.
	/// @context Model
	static get_branch = function (_id, _array = []) {
		gml_pragma("forceinline")
		
		var _node = get_node(_id)
		
		if _node != undefined {
			_node.push_branch(_array)
		}
		
		return _array
	}
	
	/// @func get_branch_id(name_or_id, [array])
	/// @desc Searches for a Node and pushes its branch into an array as IDs.
	/// @param {String|Real} name_or_id Node name or ID.
	/// @param {Array} [array] Array to push Node IDs into.
	/// @return {Array} An array containing IDs of the Node and its children.
	/// @context Model
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