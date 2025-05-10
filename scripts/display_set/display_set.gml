/// @param {Bool} fullscreen
/// @param {Real} width
/// @param {Real} height
function display_set(_fullscreen, _width, _height) {
	if _fullscreen {
		window_set_fullscreen(true)
		
		while not window_get_fullscreen() {}
	} else {
		window_set_fullscreen(false)
		
		while window_get_fullscreen() {}
		
		var _dw = display_get_width()
		var _dh = display_get_height()
		
		_width = min(_width, _dw)
		_height = min(_height, _dh)
		
		window_set_rectangle((_dw >> 1) - (_width >> 1), (_dh >> 1) - (_height >> 1), _width, _height)
	}
	
	global.freeze_step = true
}