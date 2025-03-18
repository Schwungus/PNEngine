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
	var _input = string_input(_verb, real(_player_index))
	
	if bool(_upper) {
		_input = string_upper(_input)
	}
	
	return _input
})