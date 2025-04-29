scribble_add_macro("global", function (_flag) {
	return string(global.global_flags.get(_flag))
})

scribble_add_macro("local", function (_flag) {
	return string(global.local_flags.get(_flag))
})

scribble_add_macro("static", function (_flag) {
	return string(global.static_flags.get(_flag))
})

scribble_add_macro("pstate", function (_player_index, _state) {
	return global.players[real(_player_index)].get_state(_state)
})

scribble_add_macro("input", function (_verb, _upper = false, _player_index = 0) {
	switch _verb {
		default: return ""
		
		case "up": _verb = INPUT_VERB.UP break
		case "left": _verb = INPUT_VERB.LEFT break
		case "down": _verb = INPUT_VERB.DOWN break
		case "right": _verb = INPUT_VERB.RIGHT break
		
		case "jump": _verb = INPUT_VERB.JUMP break
		case "interact": _verb = INPUT_VERB.INTERACT break
		case "attack": _verb = INPUT_VERB.ATTACK break
		
		case "inventory1": _verb = INPUT_VERB.INVENTORY1 break
		case "inventory2": _verb = INPUT_VERB.INVENTORY2 break
		case "inventory3": _verb = INPUT_VERB.INVENTORY3 break
		case "inventory4": _verb = INPUT_VERB.INVENTORY4 break
		
		case "aim": _verb = INPUT_VERB.AIM break
		case "aim_up": _verb = INPUT_VERB.AIM_UP break
		case "aim_left": _verb = INPUT_VERB.AIM_LEFT break
		case "aim_down": _verb = INPUT_VERB.AIM_DOWN break
		case "aim_right": _verb = INPUT_VERB.AIM_RIGHT break
		
		case "ui_up": _verb = INPUT_VERB.UI_UP break
		case "ui_left": _verb = INPUT_VERB.UI_LEFT break
		case "ui_down": _verb = INPUT_VERB.UI_DOWN break
		case "ui_right": _verb = INPUT_VERB.UI_RIGHT break
		case "ui_enter": _verb = INPUT_VERB.UI_ENTER break
		case "ui_click": _verb = INPUT_VERB.UI_CLICK break
		
		case "PAUSE": _verb = INPUT_VERB.PAUSE break
		case "LEAVE": _verb = INPUT_VERB.LEAVE break
	}
	
	var _input = string_input(_verb, real(_player_index))
	
	if bool(_upper) {
		_input = string_upper(_input)
	}
	
	return _input
})