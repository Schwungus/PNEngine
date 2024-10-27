enum DemoPackets {
	TERMINATE,
	PLAYER_ACTIVATE,
	PLAYER_DEACTIVATE,
	PLAYER_INPUT,
	UI_SIGNAL,
	END,
}

global.demo_write = false
global.demo_buffer = undefined
global.demo_time = 0
global.demo_next = 0

var _demo_input = array_create(INPUT_MAX_PLAYERS)
var i = 0

repeat INPUT_MAX_PLAYERS {
	_demo_input[i++] = array_create(PlayerInputs.__SIZE)
}

global.demo_input = _demo_input