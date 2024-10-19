function AssetMap() constructor {
	assets = ds_map_create()
	
	static load = function (_name) {}
	
	static loads = function () {
		var i = 0
		
		repeat argument_count {
			load(argument[i++])
		}
	}
	
	static get = function (_name) {
		gml_pragma("forceinline")
		
		return assets[? _name]
	}
	
	static fetch = function (_name) {
		gml_pragma("forceinline")
		
		load(_name)
		
		return get(_name)
	}
	
	static clear = function () {
		static keep_assets = []
		
		var _queue = self[$ "queue"]
		
		if _queue != undefined {
			repeat ds_map_size(_queue) {
				var _key = ds_map_find_first(_queue)
				
				_queue[? _key].destroy()
				ds_map_delete(_queue, _key)
			}
		}
		
		var _kept = 0
		
		repeat ds_map_size(assets) {
			var _key = ds_map_find_first(assets)
			var _asset = assets[? _key]
			
			if _asset.transient {
				keep_assets[_kept++] = _asset
			} else {
				_asset.destroy()
			}
			
			ds_map_delete(assets, _key)
		}
		
		var i = 0
		
		repeat _kept {
			var _asset = keep_assets[i++]
			
			ds_map_add(assets, _asset.name, _asset)
		}
		
		array_resize(keep_assets, 0)
	}
}