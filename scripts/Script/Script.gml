function Script() : Asset() constructor {
	parent = undefined
	imports = []
	
	main = undefined
	load = undefined
	
	static is_ancestor = function (_type) {
		if name == _type {
			return true
		}
		
		if parent != undefined {
			return parent.is_ancestor(_type)
		}
		
		return false
	}
}