event_inherited()
f_unique = true
f_visible = false
material = undefined

#region Events
Thing_event_load = event_load
Thing_event_create = event_create

event_load = function () {
	Thing_event_load()
	
	if not is_struct(special) {
		print("! Sky.load: Special properties invalid or not found")
		
		exit
	}
	
	var _material = special[$ "material"]
	
	if is_string(_material) {
		var _materials = global.materials
		
		_materials.load(_material, true)
		_material = _materials.get(_material) 
		
		if _material != undefined {
			global.models.load("mdlSky")
		}
	}
}

event_create = function () {
	Thing_event_create()
	
	if not is_struct(special) {
		print("! Sky.create: Special properties invalid or not found")
		destroy(false)
		
		exit
	}
	
	material = global.materials.get(special[$ "material"])
	mdlSky = global.models.get("mdlSky")
	
	if mdlSky != undefined {
		mdlSky.submodels[0].materials[0] = material
		model = new ModelInstance(mdlSky)
		
		var _color = color_to_vec5(special[$ "color"])
		
		model.color = _color[4]
		model.alpha = _color[3]
	}
	
	area.sky = self
}
#endregion