/// @desc Destroys the struct, disconnecting from the current session in the process.
function net_destroy() {
	with global.netgame {
		net_disconnect()
		ds_list_destroy(players)
		ds_map_destroy(clients)
		
		if ds_exists(tick_queue, ds_type_queue) {
			while ds_queue_size(tick_queue) {
				ds_queue_dequeue(tick_queue) // Delay
				buffer_delete(ds_queue_dequeue(tick_queue)) // Tick buffer
			}
			
			ds_queue_destroy(tick_queue)
		}
		
		ds_list_destroy(chat_log)
		global.netgame = undefined
	}
	
	return false
}