/// @description Create
// Feather disable GM1014
// Feather disable GM1019
// Feather disable GM2016
event_inherited()

playcam = [x, y, z]
playcam_z = z
playcam_z_to = z

camera = area.add(PlayerCamera, x, y, z, angle)

if thing_exists(camera) {
	playcam_target = camera.add_target(playcam, playcam_range, playcam_x_origin, playcam_y_origin, -height + playcam_z_origin)
	camera.pitch = 15
}