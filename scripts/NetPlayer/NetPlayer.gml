function NetPlayer() constructor {
	session = undefined
	slot = 0
	local = false
	
	ip = "127.0.0.1"
	port = 0
	key = "127.0.0.1:0"
	
	ping = 0
	ready = true
	input_queue = ds_queue_create()
	
	name = ""
	player = undefined
	
	reliable_write = ds_map_create()
	reliable_write_index = 1
	reliable_read = ds_map_create()
	reliable_read_index = 1
	
	reliable_time_source = time_source_create(time_source_global, 0.25, time_source_units_seconds, method(self, function () {
		var n = ds_map_size(reliable_write)
		
		if not n {
			time_source_stop(reliable_time_source)
			
			exit
		}
		
		var _key = ds_map_find_first(reliable_write)
		
		repeat n {
			session.send_player(self, reliable_write[? _key], undefined, false, false)
			_key = ds_map_find_next(reliable_write, _key)
		}
	}), [], -1)
}