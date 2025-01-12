function cmd_recompile() {
	CMD_NO_DEMO
	CMD_NO_NETGAME
	
	global.scripts.clear()
	cmd_level(global.level.name)
}