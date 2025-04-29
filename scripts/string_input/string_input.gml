function string_input(_verb, _player_index = 0) {
	var _binding1 = InputIconGet(_verb, 0, _player_index)
	var _binding2 = InputIconGet(_verb, 1, _player_index)
	var _text
	
	if _binding1 != "empty" and _binding1 != "unsupported" {
		_text = _binding1
		
		if _binding2 != "empty" and _binding2 != "unsupported" {
			_text += $" / {_binding2}"
		}
	} else {
		_text = (_binding2 != "empty" and _binding2 != "unsupported") ? _binding2 : lexicon_text("not_bound")
	}
	
	return _text
}