function GlobalFlags() : Flags() constructor {
	static clear = function () {
		ds_map_copy(flags, global.default_flags)
		
		return true
	}
}

global.global_flags = new GlobalFlags()
global.default_flags = ds_map_create()