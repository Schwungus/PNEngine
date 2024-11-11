if async_load[? "type"] != network_type_data {
	exit
}

switch load_state {
	case LoadStates.NONE:
	case LoadStates.CONNECT:
	case LoadStates.HOST_WAIT: break
	default: exit
}

var _ip = async_load[? "ip"]
var _port = async_load[? "port"]
var _buffer = async_load[? "buffer"]
var _reliable = buffer_read(_buffer, buffer_u32)
var _header = buffer_read(_buffer, buffer_u8)
var _netgame = global.netgame

with _netgame {
	if _reliable > 0 {
		var _key = $"{_ip}:{_port}"
		var _net = master ? clients[? _key] : players[| 0]
		
		if _net == undefined {
			print($"! proControl: Got invalid ROM from client {_key} (index {_reliable})")
			
			exit
		}
		
		with _net {
			if _reliable == reliable_read_index {
				net_process_packet(_netgame, _ip, _port, _buffer, _reliable, _header);
				++reliable_read_index
				
				while ds_map_exists(reliable_read, reliable_read_index) {
					var b = reliable_read[? reliable_read_index]
					
					net_process_packet(_netgame, _ip, _port, b, reliable_read_index, buffer_peek(b, buffer_sizeof(buffer_u32), buffer_u8))
					buffer_delete(b)
					ds_map_delete(reliable_read, reliable_read_index++)
				}
			} else {
				print($"proControl: Out of order packet from {_key} ({_reliable} =/= {reliable_read_index})")
				
				if reliable_read_index < _reliable and not ds_map_exists(reliable_read, _reliable) {
					var _size = buffer_get_size(_buffer)
					var b = buffer_create(_size, buffer_fixed, 1)
					
					buffer_copy(_buffer, 0, _size, b, 0)
					buffer_seek(b, buffer_seek_start, buffer_sizeof(buffer_u32) + buffer_sizeof(buffer_u8))
					reliable_read[? _reliable] = b
				}
			}
		}
		
		send_player(_net, net_buffer_create(false, NetHeaders.ACK, buffer_u32, _reliable))
	} else {
		net_process_packet(_netgame, _ip, _port, _buffer, _reliable, _header)
	}
}