function Handler(_handler_script) constructor {
	handler_script = _handler_script
	
	if _handler_script != undefined {
		player_connected = _handler_script.player_connected
		player_disconnected = _handler_script.player_disconnected
		player_activated = _handler_script.player_activated
		player_deactivated = _handler_script.player_deactivated
		level_started = _handler_script.level_started
		area_changed = _handler_script.area_changed
		area_activated = _handler_script.area_activated
		area_deactivated = _handler_script.area_deactivated
		ui_signalled = _handler_script.ui_signalled
	}
}