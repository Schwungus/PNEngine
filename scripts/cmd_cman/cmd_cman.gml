function cmd_cman(_args) {
	CMD_NO_NETGAME
	
	var _camera_man = global.camera_man
	
	if instance_exists(_camera_man) {
		instance_destroy(_camera_man, false)
		global.camera_man = noone
		
		exit
	}
	
	// Create cameraman from active camera
	var _camera_active = global.camera_active
	
	if instance_exists(_camera_active) {
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
		
		if instance_exists(_camera) {
			with _camera.resolve() {
				global.camera_man = area.add(Camera, x, y, z, yaw, 0, {pitch, roll, fov})
			}
			
			exit
		}
	}
}