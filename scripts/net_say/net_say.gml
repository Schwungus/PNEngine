function net_say(_text, _color = c_white) {
	with global.netgame {
		ds_list_add(chat_log, _text, _color)
		array_shift(chat_fade)
		array_push(chat_fade, current_time + 9000)
	}
	
	print($"net_say: {_text}")
}