function StaticFlags() : Flags() constructor {
	/// @param {String} key
	/// @param {Any} value
	/// @return {Bool}
	/// @context StaticFlags
	static set = function (_key, _value) {
		print("! StaticFlags.set: Not allowed")
		
		return false
	}
	
	/// @param {String} key
	/// @return {Real}
	/// @context StaticFlags
	static increment = function (_key) {
		print("! StaticFlags.increment: Not allowed")
		
		return 0
	}
	
	/// @param {Struct} struct
	/// @context StaticFlags
	static copy = function (_struct) {
		print("! StaticFlags.copy: Not allowed")
	}
	
	/// @context StaticFlags
	static clear = function () {
		print("! StaticFlags.clear: Not allowed")
		
		return false
	}
	
	/// @param {Id.Buffer} buffer
	/// @context StaticFlags
	static read = function (_buffer) {
		print("! StaticFlags.read: Not allowed")
	}
}

global.static_flags = new StaticFlags()