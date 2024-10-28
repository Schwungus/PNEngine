/// @desc Destroys the struct, disconnecting from the current session in the process.
function net_destroy() {
	with global.netgame {
		net_disconnect()
		ds_list_destroy(players)
		ds_map_destroy(clients)
		
		if ds_exists(tick_queue, ds_type_queue) {
			ds_queue_destroy(tick_queue)
		}
		
		global.netgame = undefined
	}
	
	return false
}