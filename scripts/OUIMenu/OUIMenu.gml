function OUIMenu(_name, _contents = [], _disabled = undefined) : OUIElement(_name, undefined, _disabled) constructor {
	option = 0
	contents = _contents
	
	var i = 0
	
	repeat array_length(_contents) {
		var _element = _contents[i++]
		
		if is_instanceof(_element, OUIElement) {
			_element.menu = other
			_element.slot = i
		}
	}
	
	i = 0
	
	var _oui_current = global.oui_current
	
	option = _oui_current[? _name]
	
	if option == undefined {
		repeat array_length(_contents) {
			var _element = _contents[i]
			
			if is_instanceof(_element, OUIElement) and not is_instanceof(_element, OUIText) and (_element.disabled == undefined or not _element.disabled()) {
				option = i
				_oui_current[? _name] = i
				
				break
			}
			
			++i
		}
	}
	
	from = undefined
}