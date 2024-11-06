function inject_tick_packet() {
	gml_pragma("forceinline")
	
	var _tick_buffer = global.tick_buffer
	
	if not global.inject_tick_buffer {
		buffer_seek(_tick_buffer, buffer_seek_start, 0)
		global.inject_tick_buffer = true
	}
	
	return _tick_buffer
}