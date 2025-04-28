function cmd_pos(_args) {
	var _slot = _args == "" ? "0" : _args
	
	try {
		_slot = real(_slot)
	} catch (e) {
		print("! cmd_pos: Invalid player slot")
		
		exit
	}
	
	if _slot < 0 or _slot >= MAX_PLAYERS {
		print("! cmd_pos: Player slot out of range")
		
		exit
	}
	
	with global.players[_slot] {
		if not instance_exists(thing) {
			print($"! cmd_pos: Player {-~_slot} has no Thing")
			
			exit
		}
		
		print($"XYZ: {thing.x}, {thing.y}, {thing.z}")
	}
}