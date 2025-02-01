function area_destroy(_scope) {
	with _scope {
		var i = ds_list_size(active_things)
		
		while i {
			active_things[| --i].destroy(false)
		}
		
		COLLECT_DESTROYED_START
		COLLECT_DESTROYED_END
		ds_list_destroy(active_things)
		ds_list_destroy(tick_things)
		ds_list_destroy(tick_colliders)
		ds_list_destroy(particles)
		ds_list_destroy(players)
		sounds.destroy()
		i = 0
		
		repeat ds_list_size(dsps) {
			fmod_dsp_release(dsps[| 0])
			ds_list_delete(dsps, 0)
		}
		
		ds_list_destroy(dsps)
		i = 0
		
		repeat ds_grid_width(bump_grid) {
			var j = 0
			
			repeat ds_grid_height(bump_grid) {
				ds_list_destroy(bump_grid[# i, j++])
			}
			
			++i
		}
		
		ds_grid_destroy(bump_grid)
		ds_list_destroy(lights)
	}
}