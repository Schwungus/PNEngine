function StaticFlags() : Flags() constructor {
	static set = function (_key, _value) {
		print("! StaticFlags.set: Not allowed")
		
		return false
	}
	
	static increment = function (_key) {
		print("! StaticFlags.increment: Not allowed")
		
		return 0
	}
	
	static copy = function (_struct) {
		print("! StaticFlags.copy: Not allowed")
	}
	
	static clear = function () {
		print("! StaticFlags.clear: Not allowed")
		
		return false
	}
	
	static read = function (_buffer) {
		print("! StaticFlags.read: Not allowed")
	}
}

global.static_flags = new StaticFlags()