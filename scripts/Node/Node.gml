function Node() constructor {
	index = 0
	name = ""
	parent = undefined
	children = []
	is_bone = false
	dq = dq_build_identity()
	
	/// @param {Id.Buffer} buffer
	/// @return {Struct.Node}
	/// @context Node
	static from_buffer = function (_buffer) {
		name = buffer_read(_buffer, buffer_string)
		index = buffer_read(_buffer, buffer_f32)
		is_bone = buffer_read(_buffer, buffer_bool)
		
		var i = 0
		
		repeat 8 {
			dq[i++] = buffer_read(_buffer, buffer_f32)
		}
		
		// Meshes
		var _mesh_count = buffer_read(_buffer, buffer_u32)
		
		repeat _mesh_count {
			buffer_read(_buffer, buffer_u32)
		}
		
		// Children
		var _child_count = buffer_read(_buffer, buffer_u32)
		
		array_resize(children, _child_count)
		i = 0

		repeat _child_count {
			var _child = new Node()
			
			_child.parent = self
			children[i++] = _child
			_child.from_buffer(_buffer)
		}
		
		return self
	}
	
	/// @param {Array} array
	/// @context Node
	static push_branch = function (_array) {
		array_push(_array, self)
		
		var i = 0
		
		repeat array_length(children) {
			children[i++].push_branch(_array)
		}
	}
	
	/// @param {Array} array
	/// @context Node
	static push_branch_id = function (_array) {
		array_push(_array, index)
		
		var i = 0
		
		repeat array_length(children) {
			children[i++].push_branch_id(_array)
		}
	}
}