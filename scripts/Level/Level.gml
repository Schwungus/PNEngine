function Level() constructor {
	name = ""
	areas = ds_map_create()
	
	rp_name = ""
	rp_icon = ""
	rp_time = false
	
	music = undefined
	clear_color = undefined
	ambient_color = undefined
	wind_strength = 1
	wind_direction = undefined
	gravity = 0.6
	
	time = 0
	
	static goto = function (_level, _area = 0, _tag = ThingTags.NONE, _transition = noone) {
		set_tick_scale(1)
		
		with proTransition {
			if state < 3 {
				exit
			}
		}
		
		var _script = undefined
		
		if is_string(_transition) {
			if string_starts_with(_transition, "pro") {
				show_error($"!!! Level.goto: Tried to transition to level using protected Transition '{_transition}'", true)
			}
			
			var _index = asset_get_index(_transition)
			
			if not object_exists(_index) or not object_is_ancestor(_index, proTransition) {
				_script = global.scripts.get(_transition)
				
				if _script != undefined and is_instanceof(_script, TransitionScript) {
					_index = _script.internal_parent
				} else {
					_index = noone
					print($"! Level.goto: Transition '{_transition}' not found")
				}
			}
			
			_transition = _index
		}
		
		if object_exists(_transition) and (_transition == proTransition or object_is_ancestor(_transition, proTransition)) {
			with instance_create_depth(0, 0, 0, _transition) {
				if _script != undefined {
					transition_script = _script
					reload = _script.reload
					create = _script.create
					clean_up = _script.clean_up
					tick = _script.tick
					draw_screen = _script.draw_screen
				}
				
				to_level = _level
				to_area = _area
				to_tag = _tag
				event_user(ThingEvents.CREATE)
			}
			
			exit
		}
		
		with proControl {
			load_level = _level
			load_area = _area
			load_tag = _tag
			load_state = LoadStates.START
		}
	}
	
	static area_exists = function (_id) {
		gml_pragma("forceinline")
		
		return ds_map_exists(areas, _id)
	}
	
	/// @func count(type)
	/// @desc Returns the amount of the specified Thing and its children in all active areas.
	static count = function (_type) {
		var _count = 0
		var _key = ds_map_find_first(areas)
		
		repeat ds_map_size(_key) {
			_count += areas[? _key].count(_type)
			_key = ds_map_find_next(areas, _key)
		}
		
		return _count
	}
	
	static set_tick_scale = function (_scale) {
		global.tick_scale = _scale
	}
}