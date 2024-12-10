function cmd_cman(_args) {
	CMD_NO_NETGAME
	
	var _camera_man = global.camera_man
	
	if thing_exists(_camera_man) {
		_camera_man.destroy(false)
		global.camera_man = noone
		
		exit
	}
	
	global.camera_man_freeze = string_trim(_args) == "" ? true : bool(_args)
	
	// Create cameraman from active camera
	var _camera_active = global.camera_active
	
	if thing_exists(_camera_active) {
		with _camera_active.resolve() {
			global.camera_man = area.add(Camera, x, y, z, yaw, 0, {pitch, roll, fov})
		}
		
		exit
	}
	
	// Create cameraman from first playcam
	var _players = global.players
	var i = 0
	
	repeat INPUT_MAX_PLAYERS {
		var _camera = _players[i++].camera
		
		if thing_exists(_camera) {
			with _camera.resolve() {
				global.camera_man = area.add(Camera, x, y, z, yaw, 0, {pitch, roll, fov})
			}
			
			exit
		}
	}
}