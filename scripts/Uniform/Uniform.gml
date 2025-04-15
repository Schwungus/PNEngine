enum UniformTypes {
	FLOAT,
	FLOAT_ARRAY,
	FLOAT_BUFFER,
	INTEGER,
	INTEGER_ARRAY,
	MATRIX,
	MATRIX_ARRAY,
	TEXTURE,
}

function Uniform(_name, _type) constructor {
	static last_index = 0
	
	index = last_index++
	name = _name
	type = _type
	func = undefined
	
	switch _type {
		case UniformTypes.FLOAT: func = shader_set_uniform_f break
		case UniformTypes.FLOAT_ARRAY: func = shader_set_uniform_f_array break
		case UniformTypes.FLOAT_BUFFER: func = shader_set_uniform_f_buffer break
		case UniformTypes.INTEGER: func = shader_set_uniform_i break
		case UniformTypes.INTEGER_ARRAY: func = shader_set_uniform_i_array break
		case UniformTypes.MATRIX: func = shader_set_uniform_matrix break
		case UniformTypes.MATRIX_ARRAY: func = shader_set_uniform_matrix_array break
		case UniformTypes.TEXTURE: func = texture_set_stage break
	}
	
	var _shaders = global.shaders
	var i = 0
	
	repeat ds_list_size(_shaders) {
		with _shaders[| i++] {
			/// @feather ignore GM1063 SHUT UP SHUT UP SHUT UP SHUT UP SHUT UP
			var _uniform = _type == UniformTypes.TEXTURE ? shader_get_sampler_index(shader, _name) : shader_get_uniform(shader, _name)
			
			ds_list_add(uniforms, _uniform)
		}
	}
	
	static set = function () {
		static _args = []
		
		_args[0] = global.current_shader.uniforms[| index]
		
		var i = 0
		
		repeat argument_count {
			_args[-~i] = argument[i];
			++i
		}
		
		// GROSS HACK: Can't use "-~argument_count" on YYC...
		//			   (then again, why would YOU use "-~"?)
		script_execute_ext(func, _args, 0, argument_count + 1)
	}
}