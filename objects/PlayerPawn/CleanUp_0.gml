event_inherited()

if player != undefined {
	if player.thing == self {
		player.thing = noone
	}
	
	if player.camera == camera {
		player.camera = noone
	}
}

if thing_exists(camera) {
	camera.destroy(false)
}