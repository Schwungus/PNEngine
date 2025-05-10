function GlobalFlags() : Flags() constructor {
	/// @func clear()
	/// @desc Clears all global flags.
	///       If specified in mod properties, some global flags can be set back to their default value.
	/// @return {Bool} Whether or not the flags were successfully reset.
	/// @context GlobalFlags
	static clear = function () {
		ds_map_copy(flags, global.default_flags)
		
		return true
	}
}

global.global_flags = new GlobalFlags()
global.default_flags = ds_map_create()