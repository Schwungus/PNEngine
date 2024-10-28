function NetPlayer() constructor {
	session = undefined
	slot = 0
	local = false
	
	ip = "127.0.0.1"
	port = 0
	key = "127.0.0.1:0"
	
	ping = 0
	ready = true
	tick_acked = false
	input_queue = ds_queue_create()
	
	name = ""
	player = undefined
	
	reliable_index = 0
	reliable_received = 0
	reliable = ds_list_create()
	
	reliable_time_source = time_source_create(time_source_global, 0.25, time_source_units_seconds, method(self, function () {
		if ds_list_empty(reliable) {
			time_source_stop(reliable_time_source)
			
			exit
		}
		
		session.send_player(self, reliable[| 0], undefined, false, false)
	}), [], -1)
}