function cmd_recompile() {
	CMD_NO_DEMO
	
	global.scripts.clear()
	cmd_level(global.level.name)
}