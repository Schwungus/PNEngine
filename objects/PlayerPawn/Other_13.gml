/// @description Tick
event_inherited()

if thing_exists(self) and player != undefined {
	catspeak_execute(player_update)
	catspeak_execute(player_update_camera)
}