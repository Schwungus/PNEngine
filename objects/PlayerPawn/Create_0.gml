event_inherited()

#region Variables
player = undefined
input = undefined
input_previous = undefined
camera = noone

input_length = 0
jumped = false
coyote = 0

can_aim = true
aiming = false
aim_angle = 0
nearest_target = noone
nearest_holdable = noone
nearest_interactive = noone

movement_speed = 6
jump_speed = -6.44
coyote_time = 4
can_maneuver = true
can_hold = true
can_interact = true

lock_animation = false

playcam_range = 128
playcam_x_origin = 0
playcam_y_origin = 0
playcam_z_origin = -4
playcam_z_lerp = 0.25
playcam_z_snap = false
playcam_target = undefined
#endregion

#region Functions
jump = function (_spd) {
	// GROSS HACK: Override the jump function so player input doesn't
	//			   affect the specified speed
	z_speed = _spd
	floor_ray[RaycastData.HIT] = false
	f_grounded = false
	jumped = false
}

do_jump = function () {
	z_speed = jump_speed
	floor_ray[RaycastData.HIT] = false
	f_grounded = false
	coyote = 0
	jumped = true
	catspeak_execute(player_jumped)
}

do_maneuver = function () {
	catspeak_execute(player_maneuvered)
}

do_attack = function () {
	if thing_exists(holding) and not holding.f_holdable_in_hand {
		do_unhold(true)
		
		exit
	}
	
	catspeak_execute(player_attacked)
}

get_state = function (_key) {
	gml_pragma("forceinline")
	
	if player == undefined {
		return undefined
	}
	
	return player.get_state(_key)
}

set_state = function (_key, _value) {
	gml_pragma("forceinline")
	
	if player == undefined {
		return false
	}
	
	return player.set_state(_key, _value)
}

reset_state = function (_key) {
	gml_pragma("forceinline")
	
	if player == undefined {
		return undefined
	}
	
	return player.reset_state(_key)
}

respawn = function () {
	gml_pragma("forceinline")
	
	if player == undefined {
		destroy(false)
		
		return noone
	}
	
	return player.respawn()
}

is_local = function () {
	gml_pragma("forceinline")
	
	if player == undefined {
		return false
	}
	
	return player.is_local()
}
#endregion

#region Virtual Functions
try_jump = function () {
	return true
}

player_jumped = function () {}

try_maneuver = function () {
	return true
}

player_maneuvered = function () {}

try_attack = function () {
	return true
}

player_attacked = function () {}
player_aimed = function (_target) {}
player_respawned = function () {}
player_create = function () {}
player_update = function () {}
player_update_camera = function () {}
#endregion

#region Events
Thing_event_load = event_load
Thing_event_create = event_create
Thing_event_tick = event_tick

event_load = function () {
	Thing_event_load()
	ui_load("Pause")
}

event_create = function () {
	Thing_event_create()
	playcam = [x, y, z]
	playcam_z = z
	playcam_z_to = z
	camera = area.add(PlayerCamera, x, y, z, angle)
	
	if thing_exists(camera) {
		playcam_target = camera.add_target(playcam, playcam_range, playcam_x_origin, playcam_y_origin, -height + playcam_z_origin)
		camera.pitch = 15
	}
}

event_tick = function () {
	Thing_event_tick()
	
	if thing_exists(self) and player != undefined {
		catspeak_execute(player_update)
		catspeak_execute(player_update_camera)
	}
}
#endregion