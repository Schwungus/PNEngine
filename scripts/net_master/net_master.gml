function net_master() {
	gml_pragma("forceinline")
	
	var _netgame = global.netgame
	
	if _netgame == undefined {
		return true
	}
	
	return _netgame == undefined or (_netgame.active and _netgame.master)
}