function level_destroy(_scope) {
	with _scope {
		repeat ds_map_size(areas) {
			var _key = ds_map_find_first(areas)
			
			area_destroy(areas[? _key])
			ds_map_delete(areas, _key)
		}
		
		ds_map_destroy(areas)
	}
}