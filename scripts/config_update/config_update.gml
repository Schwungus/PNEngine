function config_update() {
	gml_pragma("forceinline")
	
	struct_foreach(global.config, function (_name, _value) {
		with _value {
			if update != undefined {
				update(true)
			}
		}
	})
}