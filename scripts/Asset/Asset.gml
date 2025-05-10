function Asset() constructor {
	name = ""
	transient = false
	
	static destroy = function () {}
	
	/// @param {Array} array
	static destroy_array = function (_array) {
		if not is_array(_array) {
			exit
		}
		
		var i = 0
		
		repeat array_length(_array) {
			_array[i++].destroy()
		}
	}
}