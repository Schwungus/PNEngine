function Handler(_handler_script) constructor {
	handler_script = _handler_script
	
#region Functions
	/// @func find(name)
	/// @desc Finds a Handler.
	/// @param {String} name Handler name.
	/// @return {Struct.Handler|Undefined}
	/// @context Handler
	static find = function (_name) {
		gml_pragma("forceinline")
		
		return global.handlers[? _name]
	}
#endregion
	
#region Virtual Functions
	// Internal
	on_register = undefined
	on_start = undefined
	
	// Player
	player_activated = undefined
	player_deactivated = undefined
	
	// Level
	level_started = undefined
	level_loading = undefined
	
	// Area
	area_activated = undefined
	area_deactivated = undefined
	area_changed = undefined
	
	// UI
	ui_signalled = undefined
	
	if _handler_script != undefined {
		on_register = _handler_script.on_register
		on_start = _handler_script.on_start
		
		player_activated = _handler_script.player_activated
		player_deactivated = _handler_script.player_deactivated
		
		level_started = _handler_script.level_started
		level_loading = _handler_script.level_loading
		
		area_activated = _handler_script.area_activated
		area_deactivated = _handler_script.area_deactivated
		area_changed = _handler_script.area_changed
		
		ui_signalled = _handler_script.ui_signalled
	}
#endregion
}