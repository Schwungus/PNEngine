/// @param {String} args
function cmd_pseq(_args) {
	var _parse_args = string_split(_args, " ", true)
	var n = array_length(_parse_args)
	
	if n < 2 {
		print("Usage: pseq <player> <sequence>")
		
		exit
	}
	
	CMD_NO_DEMO
	
	var _slot = real(_parse_args[0])
	
	if _slot < 0 or _slot >= MAX_PLAYERS {
		print($"! cmd_pseq: Invalid player index '{_slot}' out of '{MAX_PLAYERS}'")
	}
	
	var _pawn = global.players[_slot].thing
	
	if thing_exists(_pawn) {
		_pawn.do_sequence(_parse_args[1])
	}
}