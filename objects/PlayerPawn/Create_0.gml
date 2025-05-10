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
/// @func jump(speed)
/// @desc Ungrounds the pawn and makes it jump.
/// @param {Real} speed
/// @context PlayerPawn
jump = function (_spd) {
	// GROSS HACK: Override the jump function so player input doesn't
	//			   affect the specified speed
	z_speed = _spd
	floor_ray[RaycastData.HIT] = false
	f_grounded = false
	jumped = false
}

/// @func do_jump()
/// @context PlayerPawn
do_jump = function () {
	z_speed = jump_speed
	floor_ray[RaycastData.HIT] = false
	f_grounded = false
	coyote = 0
	jumped = true
	catspeak_execute(player_jumped)
}

/// @func do_maneuver()
/// @context PlayerPawn
do_maneuver = function () {
	catspeak_execute(player_maneuvered)
}

/// @func do_attack()
/// @context PlayerPawn
do_attack = function () {
	if thing_exists(holding) and not holding.f_holdable_in_hand {
		do_unhold(true)
		
		exit
	}
	
	catspeak_execute(player_attacked)
}

/// @func get_state(key)
/// @param {String} key
/// @return {Any}
/// @context PlayerPawn
get_state = function (_key) {
	gml_pragma("forceinline")
	
	if player == undefined {
		return undefined
	}
	
	return player.get_state(_key)
}

/// @func get_state(key, value)
/// @param {String} key
/// @param {Any} value
/// @return {Bool}
/// @context PlayerPawn
set_state = function (_key, _value) {
	gml_pragma("forceinline")
	
	if player == undefined {
		return false
	}
	
	return player.set_state(_key, _value)
}

/// @func reset_state(key)
/// @param {String} key
/// @return {Any}
/// @context PlayerPawn
reset_state = function (_key) {
	gml_pragma("forceinline")
	
	if player == undefined {
		return undefined
	}
	
	return player.reset_state(_key)
}

/// @func respawn()
/// @return {Id.Instance}
/// @context PlayerPawn
respawn = function () {
	gml_pragma("forceinline")
	
	if player == undefined {
		destroy(false)
		
		return noone
	}
	
	return player.respawn()
}

/// @func is_local()
/// @return {Bool}
/// @context PlayerPawn
is_local = function () {
	gml_pragma("forceinline")
	
	if player == undefined {
		return false
	}
	
	return player.is_local()
}
#endregion

#region Virtual Functions
/// @func try_jump()
/// @return {Bool}
/// @context PlayerPawn
try_jump = function () {
	return true
}

/// @func player_jumped()
/// @context PlayerPawn
player_jumped = function () {}

/// @func try_maneuver()
/// @return {Bool}
/// @context PlayerPawn
try_maneuver = function () {
	return true
}

/// @func player_maneuvered()
/// @context PlayerPawn
player_maneuvered = function () {}

/// @func try_attack()
/// @return {Bool}
/// @context PlayerPawn
try_attack = function () {
	return true
}

/// @func player_attacked()
/// @context PlayerPawn
player_attacked = function () {}

/// @func player_aimed(target)
/// @param {Id.Instance} target
/// @context PlayerPawn
player_aimed = function (_target) {}

/// @func player_respawned()
/// @context PlayerPawn
player_respawned = function () {}

/// @func player_create()
/// @context PlayerPawn
player_create = function () {}

/// @func player_update()
/// @context PlayerPawn
player_update = function () {}

/// @func player_update_camera()
/// @context PlayerPawn
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