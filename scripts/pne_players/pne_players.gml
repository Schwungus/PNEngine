#macro MAX_PLAYERS 4
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
	INVENTORY1,
	INVENTORY2,
	INVENTORY3,
	INVENTORY4,
	AIM,
	AIM_UP_DOWN,
	AIM_LEFT_RIGHT,
	__SIZE,
}

enum PIFlags {
	JUMP = 1 << 0,
	INTERACT = 1 << 1,
	ATTACK = 1 << 2,
	INVENTORY1 = 1 << 3,
	INVENTORY2 = 1 << 4,
	INVENTORY3 = 1 << 5,
	INVENTORY4 = 1 << 6,
	AIM = 1 << 7,
}

global.players_active = ds_list_create()
global.players_ready = ds_list_create()
global.default_states = ds_map_create()

var _players = array_create(MAX_PLAYERS)
var i = 0

repeat MAX_PLAYERS {
	var _player = new Player()
	
	with _player {
		slot = i
		
		if i == 0 {
			player_activate(self, false)
		}
	}
	
	_players[i++] = _player
}

global.players = _players
InputPartySetParams(INPUT_VERB.UI_ENTER, 1, MAX_PLAYERS, false, INPUT_VERB.LEAVE)