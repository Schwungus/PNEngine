function cmd_md5(_args) {
	var _parse_args = string_split(_args, " ", true)
	var n = array_length(_parse_args)
	
	if n == 0 {
		print("Usage: md5 <file>")
		
		exit
	}
	
	var _filename = _parse_args[0]
	var _file = mod_find_file(_filename)
	
	if _file == "" {
		print($"! cmd_md5: File '{_filename}' not found")
		
		exit
	}
	
	print(md5_file(_file))
}