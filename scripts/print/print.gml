#macro __show_debug_message show_debug_message
#macro show_debug_message print

/// @func print(str, [values...])
/// @desc Prints a message to the console.
/// @param {String|Any} str Value or string format to use for printing.
/// @param {Any} [values...] Values to apply to a string format.
function print(_str) {
	static _values = []
	static _init = false
	
	array_resize(_values, 0)
	
	var i = 0
	
	repeat argument_count - 1 {
		var j = -~i
		
		_values[i] = argument[j]
		i = j
	}
	
	var _output = string_ext(string(_str), _values)
	
	__show_debug_message(_output)
	
	// Failsafe for scripts that run before pn_debug
	if not _init {
		if not variable_global_exists("console_log") {
			global.console_log = ds_list_create()
		}
		
		_init = true
	}
	
	var _console_log = global.console_log
	
	ds_list_add(global.console_log, _output)
}