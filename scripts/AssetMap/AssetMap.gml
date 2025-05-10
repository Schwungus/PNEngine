function AssetMap() constructor {
	assets = ds_map_create()
	
	/// @func load(name)
	/// @desc Loads an Asset.
	/// @param {String} name Asset file name.
	/// @context AssetMap
	static load = function (_name) {}
	
	/// @func loads([names...])
	/// @desc Loads multiple Assets.
	/// @param {String} [names...] Asset file names.
	/// @context AssetMap
	static loads = function () {
		var i = 0
		
		repeat argument_count {
			load(argument[i++])
		}
	}
	
	/// @func get(name)
	/// @desc Returns an Asset.
	/// @param {String} [name] Asset name.
	/// @return {Struct.Asset|Undefined}
	/// @context AssetMap
	static get = function (_name) {
		gml_pragma("forceinline")
		
		return assets[? _name]
	}
	
	/// @func fetch(name)
	/// @desc Loads an Asset if it isn't already loaded, then returns it.
	/// @param {String} [name] Asset name or file name.
	/// @return {Struct.Asset|Undefined}
	/// @context AssetMap
	static fetch = function (_name) {
		gml_pragma("forceinline")
		
		load(_name)
		
		return get(_name)
	}
	
	/// @func clear()
	/// @desc Destroys all non-transient loaded Assets.
	/// @context AssetMap
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