function cmd_drec(_args) {
	if global.demo_write {
		print("! cmd_drec: Already recording")
		
		exit
	}
	
	if global.demo_buffer != undefined {
		print("! cmd_drec: Cannot record during a demo")
		
		exit
	}
	
	global.demo_write = true
	print("cmd_drec: Demo recording will start on level change")
}