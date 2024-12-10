function thing_exists(_thing) {
	gml_pragma("forceinline")
	
	return instance_exists(_thing) and not _thing.f_destroyed
}