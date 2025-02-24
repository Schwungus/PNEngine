function net_active() {
	gml_pragma("forceinline")
	
	var _netgame = global.netgame
	
	return _netgame != undefined and _netgame.active
}