/// @desc Resets the user config to its default values.
function config_reset() {
	struct_foreach(global.config, function (_name, _value) {
		with _value {
			set(default_value, false)
		}
	})
	
	config_update()
	InputBindingsReset(false)
	InputBindingsReset(true)
}