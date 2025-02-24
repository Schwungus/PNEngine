if async_load[? "type"] != network_type_data {
	exit
}

switch load_state {
	case LoadStates.NONE:
	case LoadStates.CONNECT:
	default: exit
}

var _ip = async_load[? "ip"]
var _port = async_load[? "port"]
var _buffer = async_load[? "buffer"]
var _reliable = buffer_read(_buffer, buffer_u16)
var _header = buffer_read(_buffer, buffer_u8)
var _netgame = global.netgame

with _netgame {}