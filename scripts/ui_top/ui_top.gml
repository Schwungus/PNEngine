function ui_top() {
	var _top = global.ui
			
	while _top != undefined {
		var _child = _top.child
				
		if _child == undefined {
			break
		}
				
		_top = _child
	}
			
	return _top
}