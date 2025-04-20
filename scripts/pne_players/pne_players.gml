#macro PLAYER_INPUT_INVERSE 0.0078740157480315
#macro PLAYER_AIM_INVERSE 0.010986328125
#macro PLAYER_AIM_DIRECT 91.02222222222222

enum PlayerStatus {
	INACTIVE,
	PENDING,
	ACTIVE,
}

enum PlayerInputs {
	UP_DOWN,
	LEFT_RIGHT,
	JUMP,
	INTERACT,
	ATTACK,
	INVENTORY_UP,
	INVENTORY_LEFT,
	INVENTORY_DOWN,
	INVENTORY_RIGHT,
	AIM,
	AIM_UP_DOWN,
	AIM_LEFT_RIGHT,
	__SIZE,
}

enum PIFlags {
	JUMP = 1 << 0,
	INTERACT = 1 << 1,
	ATTACK = 1 << 2,
	INVENTORY_UP = 1 << 3,
	INVENTORY_LEFT = 1 << 4,
	INVENTORY_DOWN = 1 << 5,
	INVENTORY_RIGHT = 1 << 6,
	AIM = 1 << 7,
}

global.players_active = ds_list_create()
global.players_ready = ds_list_create()
global.default_states = ds_map_create()

var _players = array_create(INPUT_MAX_PLAYERS)
var i = 0

repeat INPUT_MAX_PLAYERS {
	var _player = new Player()
	
	with _player {
		slot = i
		
		if i == 0 {
			__show_reconnect_caption = false
			player_activate(self)
		}
	}
	
	_players[i++] = _player
}

global.players = _players
global.input_mode = INPUT_SOURCE_MODE.FIXED
input_join_params_set(1, INPUT_MAX_PLAYERS, "leave", undefined, false)
input_source_mode_set(global.input_mode)
input_cursor_coord_space_set(INPUT_COORD_SPACE.GUI, all)