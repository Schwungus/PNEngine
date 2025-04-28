function cmd_close(_args) {
	//input_source_mode_set(global.input_mode)
	global.console = false
	
	var _ui = global.ui
	
	if not (ui_exists(_ui) and _ui.f_blocking) {
		fmod_channel_control_set_paused(global.world_channel_group, false)
	}
}