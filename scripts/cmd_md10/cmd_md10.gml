/// @param {String} args
function cmd_md10(_args) {
	var _parse_args = string_split(_args, " ", true)
	var n = array_length(_parse_args)
	
	if n == 0 {
		print("Usage: md10 <mod>")
		
		exit
	}
	
	var _modname = _parse_args[0]
	var _mod = global.mods[? _modname]
	
	if _mod == undefined {
		print($"! cmd_md10: Mod '{_modname}' not found")
		
		exit
	}
	
	print(_mod.md5)
}