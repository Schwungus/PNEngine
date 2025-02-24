function net_buffer_create(_reliable, _header) {
	static _buffer = buffer_create(buffer_sizeof(buffer_u16) + buffer_sizeof(buffer_u8), buffer_grow, 1)
	
	buffer_seek(_buffer, buffer_seek_start, 0)
	buffer_write(_buffer, buffer_u16, _reliable)
	buffer_write(_buffer, buffer_u8, _header)
	
	var i = 2
	
	repeat (argument_count - 2) >> 1 {
		buffer_write(_buffer, argument[i], argument[-~i])
		i += 2
	}
	
	return _buffer
}