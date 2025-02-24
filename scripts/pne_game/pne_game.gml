#region Game State
enum GameStatus {
	DEFAULT,
	NETGAME = 1 << 0,
	DEMO = 1 << 1,
}

enum LoadStates {
	NONE,
	START,
	UNLOAD,
	LOAD,
	FINISH,
	CONNECT,
}

enum TickPackets {
	CHECKSUM,
	ACTIVATE,
	DEACTIVATE,
	INPUT,
	SIGNAL,
	LEVEL,
}

enum InterpData {
	IN,
	OUT,
	IN_HASH,
	OUT_HASH,
	PREVIOUS_VALUE,
	ANGLE,
}

global.game_status = GameStatus.DEFAULT
global.game_rpc_id = ""

global.freeze_step = true
global.tick = 0
global.tick_scale = 1
global.delta = 1
global.tick_buffer = buffer_create(1, buffer_grow, 1)
global.inject_tick_buffer = false

global.mouse_focused = false

global.interps = ds_list_create()

global.saves = ds_list_create()
global.save_name = "Debug"
global.title_start = true
global.title_delete_state = 0

global.bump_stack = ds_stack_create()
global.destroyed_things = ds_list_create()

#macro COLLECT_DESTROYED_START var _destroyed_things = global.destroyed_things

#macro COLLECT_DESTROYED_END repeat ds_list_size(_destroyed_things) {\
	var _thing = _destroyed_things[| 0]\
	\
	/*print($"Destroying {_thing.get_name()}")*/\
	instance_destroy(_thing)\
	ds_list_delete(_destroyed_things, 0)\
}

#endregion

#region Levels
global.checkpoint = ["lvlTitle", 0, ThingTags.NONE]
global.level = new Level()
#endregion

#region Things
enum ThingEvents {
	LOAD,
	CREATE,
	TICK_START, // Unused
	TICK,
	TICK_END, // Unused
	DRAW,
	DRAW_SCREEN,
	DRAW_GUI,
}

enum ThingTags {
	PLAYERS = -1,
	FRIENDS = -2,
	ENEMIES = -3,
	NONE = -4, // noone
	ALL = -5,
	PLAYER_SPAWNS = -6,
}

enum DamageResults {
	NONE,
	HIT = 1 << 0,
	MISSED = 1 << 1,
	BLOCKED = 1 << 2,
	ABSORBED = 1 << 3,
	DAMAGED = 1 << 4,
	FATAL = 1 << 5,
}
#endregion