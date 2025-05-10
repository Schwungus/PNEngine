function Shader(_shader) constructor {
	if not shader_is_compiled(_shader) {
		show_error($"!!! Shader: Failed to compile '{shader_get_name(_shader)}'", true)
	}
	
	shader = _shader
	uniforms = ds_list_create()
	
	/// @func set()
	/// @desc Sets as the current shader.
	/// @context Shader
	static set = function () {
		shader_set(shader)
		global.current_shader = self
	}
	
	ds_list_add(global.shaders, self)
}