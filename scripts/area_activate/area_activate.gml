/// @param {Struct.Area} area
function area_activate(_scope) {
	with _scope {
		if active {
			exit
		}
		
		var i = 0
		
		repeat array_length(things) {
			var _element = things[i++]
			
			if _element.disposed or thing_exists(_element.thing) {
				continue
			}
			
			var _level, _area, _type, _x, _y, _z, _angle, _tag, _special, _persistent, _disposable
			
			with _element {
				_level = level
				_area = area
				_type = type
				_x = x
				_y = y
				_z = z
				_angle = angle
				_tag = tag
				_special = special
				_persistent = persistent
				_disposable = disposable
			}
			
			var _thing = noone
			
			if is_string(_type) {
				var _idx = asset_get_index(_type)
				
				if object_exists(_idx) {
					if not object_is_ancestor(_type, Thing) {
						print($"! Area.add: Tried to add non-Thing '{_type}'")
						
						continue
					}
					
					if string_starts_with(_type, "pro") {
						print($"! Area.add: Tried to add protected Thing '{_type}'")
						
						continue
					}
					
					_thing = instance_create_depth(_x, _y, 0, _idx)
				}
			} else {
				if object_exists(_type) {
					if not object_is_ancestor(_type, Thing) {
						print($"! Area.add: Tried to add non-Thing '{_type}'")
						
						continue
					}
					
					_thing = instance_create_depth(_x, _y, 0, _type)
				}
			}
			
			if _thing == noone {
				var _thing_script = global.scripts.get(_type)
				
				if _thing_script == undefined {
					instance_destroy(_thing, false)
					print($"! Area.add: Unknown Thing '{_type}'")
					
					continue
				}
				
				_thing = instance_create_depth(_x, _y, 0, _thing_script.internal_parent)
				
				with _thing {
					thing_script = _thing_script
					create = _thing_script.create
					on_destroy = _thing_script.on_destroy
					clean_up = _thing_script.clean_up
					tick_start = _thing_script.tick_start
					tick = _thing_script.tick
					tick_end = _thing_script.tick_end
					draw = _thing_script.draw
					draw_screen = _thing_script.draw_screen
					draw_gui = _thing_script.draw_gui
				}
			}
			
			with _thing {
				_thing = self
				level = _level
				area = _area
				area_thing = _element
				
				z = _z
				z_start = _z
				z_previous = _z
				angle = _angle
				angle_start = _angle
				angle_previous = _angle
				tag = _tag
				special = _special
				f_persistent = _persistent
				f_disposable = _disposable
				f_new = true
			}
			
			ds_list_add(active_things, _thing)
		}
		
		i = ds_list_size(active_things)
		
		while i {
			with active_things[| --i] {
				if f_new and not f_created {
					event_create()
					f_created = true
					ds_list_add(collider != undefined ? other.tick_colliders : other.tick_things, self)
				}
			}
		}
		
		active = true
		
		HANDLER_FOREACH_START
			if area_activated != undefined {
				catspeak_execute(area_activated, other)
			}
		HANDLER_FOREACH_END
	}
}