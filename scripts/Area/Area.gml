function Area() constructor {
	level = undefined
	slot = -1
	active = false
	master = undefined
	players = ds_list_create()
	
	sky = noone
	model = undefined
	collider = undefined
	things = []
	
	active_things = ds_list_create()
	tick_things = ds_list_create()
	tick_colliders = ds_list_create()
	particles = ds_list_create()
	lights = ds_list_create()
	
	repeat MAX_LIGHTS {
		ds_list_add(lights, noone)
	}
	
	light_data = array_create(MAX_LIGHTS * LightData.__SIZE)
	sounds = new WorldSoundPool()
	dsps = ds_list_create()
	
	bump_x = 0
	bump_y = 0
	bump_grid = ds_grid_create(1, 1)
	
	clear_color = undefined
	ambient_color = undefined
	fog_distance = undefined
	fog_color = undefined
	wind_strength = 1
	wind_direction = undefined
	gravity = 0.3
	
	/// @func add(type, [x], [y], [z], [angle], [tag], [special])
	/// @desc Creates a new Thing.
	/// @param {Asset.GMObject|String} type Thing type.
	/// @param {Real} [x] X position.
	/// @param {Real} [y] Y position.
	/// @param {Real} [z] Z position.
	/// @param {Real} [angle] Initial angle.
	/// @param {Real} [tag] Tag for special behaviour.
	/// @param {Real} [Any] Custom properties for special behaviour.
	/// @return {Id.Instance}
	/// @context Area
	static add = function (_type, _x = 0, _y = 0, _z = 0, _angle = 0, _tag = 0, _special = undefined) {
		var _thing = noone
		
		if is_string(_type) {
			var _idx = asset_get_index(_type)
			
			if object_exists(_idx) {
				if not object_is_ancestor(_idx, Thing) {
					print($"! Area.add: Tried to add non-Thing '{_type}'")
					
					return noone
				}
				
				if string_starts_with(_type, "pro") {
					print($"! Area.add: Tried to add protected Thing '{_type}'")
					
					return noone
				}
				
				_thing = instance_create_depth(_x, _y, 0, _idx)
			}
		} else if object_exists(_type) {
			if not object_is_ancestor(_type, Thing) {
				print($"! Area.add: Tried to add non-Thing '{_type}'")
				
				return noone
			}
			
			_thing = instance_create_depth(_x, _y, 0, _type)
		}
		
		if _thing == noone {
			var _thing_script = global.scripts.get(_type)
			
			if _thing_script == undefined {
				instance_destroy(_thing, false)
				print($"! Area.add: Unknown Thing '{_type}'")
				
				return noone
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
			area = other
			level = other.level
			z = _z
			z_start = _z
			z_previous = _z
			angle = _angle
			angle_start = _angle
			angle_previous = _angle
			tag = _tag
			special = _special
			f_new = true
			event_create()
			f_created = true
		}
		
		// Failsafe, Things can get destroyed while being created
		if not thing_exists(_thing) {
			return noone
		}
		
		ds_list_add(active_things, _thing)
		ds_list_add(_thing.collider != undefined ? tick_colliders : tick_things, _thing)
		
		return _thing
	}
	
	/// @func add_particle(x, y, z)
	/// @desc Creates a new particle.
	/// @param {Real} x
	/// @param {Real} y
	/// @param {Real} z
	/// @return {Array<Any>} Particle data.
	/// @context Area
	static add_particle = function (_x, _y, _z) {
		var _particle
		var _dead_particle = ds_stack_pop(global.dead_particles)
		
		// Add or replace particle data
		if _dead_particle == undefined {
			// Create a new particle or replace the oldest one
			if ds_list_size(particles) < MAX_PARTICLES {
				_particle = array_create(ParticleData.__SIZE)
				ds_list_add(particles, _particle)
			} else {
				_particle = particles[| 0]
				ds_list_delete(particles, 0)
				ds_list_add(particles, _particle)
			}
		} else {
			// Replace the oldest dead particle
			_particle = _dead_particle
			ds_list_add(particles, _particle)
		}
		
		_particle[ParticleData.DEAD] = false
		_particle[ParticleData.IMAGE] = undefined
		_particle[ParticleData.FRAME] = 0
		_particle[ParticleData.FRAME_SPEED] = 1
		_particle[ParticleData.ANIMATION] = ParticleAnimations.PLAY
		_particle[ParticleData.ALPHA_TEST] = 0
		_particle[ParticleData.FILTER] = true
		_particle[ParticleData.WIDTH] = 1
		_particle[ParticleData.WIDTH_SPEED] = 0
		_particle[ParticleData.HEIGHT] = 1
		_particle[ParticleData.HEIGHT_SPEED] = 0
		_particle[ParticleData.FLAT] = false
		_particle[ParticleData.ANGLE] = 0
		_particle[ParticleData.ANGLE_SPEED] = 0
		_particle[ParticleData.PITCH] = 0
		_particle[ParticleData.PITCH_SPEED] = 0
		_particle[ParticleData.ROLL] = 0
		_particle[ParticleData.ROLL_SPEED] = 0
		_particle[ParticleData.COLOR] = c_white
		_particle[ParticleData.ALPHA] = 1
		_particle[ParticleData.ALPHA_SPEED] = 0
		_particle[ParticleData.BRIGHT] = 0
		_particle[ParticleData.BRIGHT_SPEED] = 0
		_particle[ParticleData.BLENDMODE] = bm_normal
		_particle[ParticleData.TICKS] = infinity
		_particle[ParticleData.X] = _x
		_particle[ParticleData.Y] = _y
		_particle[ParticleData.Z] = _z
		_particle[ParticleData.FLOOR_Z] = infinity
		_particle[ParticleData.CEILING_Z] = -infinity
		_particle[ParticleData.X_SPEED] = 0
		_particle[ParticleData.Y_SPEED] = 0
		_particle[ParticleData.Z_SPEED] = 0
		_particle[ParticleData.X_FRICTION] = 1
		_particle[ParticleData.Y_FRICTION] = 1
		_particle[ParticleData.Z_FRICTION] = 1
		_particle[ParticleData.GRAVITY] = 0
		_particle[ParticleData.MAX_FLY_SPEED] = infinity
		_particle[ParticleData.MAX_FALL_SPEED] = -infinity
		
		return _particle
	}
	
	/// @func count(type)
	/// @desc Returns the amount of the specified Thing and its children in the area.
	/// @param {Asset.GMObject|String} type
	/// @return {Real}
	/// @context Area
	static count = function (_type) {
		var n = 0
		var i = ds_list_size(active_things)
		
		while i {
			if active_things[| --i].is_ancestor(_type) {
				++n
			}
		}
		
		return n
	}
	
	/// @func nearest(x, y, z, type)
	/// @desc Returns the specified Thing or its children nearest to the given point.
	/// @param {Real} x
	/// @param {Real} y
	/// @param {Real} z
	/// @param {Asset.GMObject|String} type
	/// @return {Id.Instance}
	/// @context Area
	static nearest = function (_x, _y, _z, _type) {
		var _result = noone
		var _distance = infinity
		
		var i = ds_list_size(active_things)
		
		while i {
			with active_things[| --i] {
				if is_ancestor(_type) {
					var _newdist = point_distance_3d(_x, _y, _z, x, y, z)
					
					if _newdist < _distance {
						_result = self
						_distance = _newdist
					}
				}
			}
		}
		
		return _result
	}
	
	/// @func furthest(x, y, z, type)
	/// @desc Returns the specified Thing or its children farthest from the given point.
	/// @param {Real} x
	/// @param {Real} y
	/// @param {Real} z
	/// @param {Asset.GMObject|String} type
	/// @return {Id.Instance}
	/// @context Area
	static furthest = function (_x, _y, _z, _type) {
		var _result = noone
		var _distance = -infinity
		
		var i = ds_list_size(active_things)
		
		while i {
			with active_things[| --i] {
				if is_ancestor(_type) {
					var _newdist = point_distance_3d(_x, _y, _z, x, y, z)
					
					if _newdist > _distance {
						_result = self
						_distance = _newdist
					}
				}
			}
		}
		
		return _result
	}
	
	/// @func find(type)
	/// @desc Finds a Thing of a specific type.
	/// @param {Asset.GMObject|String} type
	/// @return {Id.Instance} First result.
	/// @context Area
	static find = function (_type) {
		var i = ds_list_size(active_things)
		
		while i {
			with active_things[| --i] {
				if is_ancestor(_type) {
					return self
				}
			}
		}
		
		return noone
	}
	
	/// @func find_tag(tag)
	/// @desc Finds all Things with a specific tag.
	/// @param {Real|Enum.ThingTags} tag
	/// @return {Array<Id.Instance>} Array of all tagged Things.
	/// @context Area
	static find_tag = function (_tag) {
		static things = []
		
		var i = 0
		var j = 0
		
		switch _tag {
			case ThingTags.ALL:
				repeat ds_list_size(active_things) {
					with active_things[| i++] {
						things[j++] = self
					}
				}
				
				break
			
			case ThingTags.PLAYERS:
				repeat ds_list_size(active_things) {
					with active_things[| i++] {
						if is_ancestor(PlayerPawn) {
							things[j++] = self
						}
					}
				}
				
				break
			
			case ThingTags.PLAYER_SPAWNS:
				repeat ds_list_size(active_things) {
					with active_things[| i++] {
						if is_ancestor(PlayerSpawn) {
							things[j++] = self
						}
					}
				}
				
				break
			
			default:
				repeat ds_list_size(active_things) {
					with active_things[| i++] {
						if tag == _tag {
							things[j++] = self
						}
					}
				}
		}
		
		array_resize(things, j)
		
		return things
	}
	
	/// @func find_tag_first(tag)
	/// @desc Finds a Thing with a specific tag.
	/// @param {Real|Enum.ThingTags} tag
	/// @return {Id.Instance} First result.
	/// @context Area
	static find_tag_first = function (_tag) {
		var i = 0
		
		switch _tag {
			case ThingTags.ALL: return active_things[| 0]
			
			case ThingTags.PLAYERS:
				repeat ds_list_size(active_things) {
					with active_things[| i++] {
						if is_ancestor(PlayerPawn) {
							return self
						}
					}
				}
				
				break
			
			case ThingTags.PLAYER_SPAWNS:
				repeat ds_list_size(active_things) {
					with active_things[| i++] {
						if is_ancestor(PlayerSpawn) {
							return self
						}
					}
				}
				
				break
			
			default:
				repeat ds_list_size(active_things) {
					with active_things[| i++] {
						if tag == _tag {
							return self
						}
					}
				}
		}
		
		return noone
	}
	
	/// @func exists(thing)
	/// @desc Checks if a Thing or type exists in the area.
	/// @param {Id.Instance|Asset.GMObject|String} thing
	/// @return {Bool}
	/// @context Area
	static exists = function (_thing) {
		if is_string(_thing) {
			var i = 0
			
			repeat ds_list_size(active_things) {
				var _element = active_things[| i++]
				
				if not _element.f_destroyed and _element.is_ancestor(_thing) {
					return true
				}
			}
			
			return false
		}
		
		if is_real(_thing) {
			return array_length(find_tag(_thing)) > 0
		}
		
		return thing_exists(_thing)
	}
	
	/// @func player_count()
	/// @desc Returns the amount of players in the area.
	/// @return {Real}
	/// @context Area
	static player_count = function () {
		gml_pragma("forceinline")
		
		return ds_list_size(players)
	}
	
	/// @func get_player(index)
	/// @desc Gets a player in the area.
	/// @param {Real} index
	/// @return {Struct.Player|Undefined}
	/// @context Area
	static get_player = function (_index) {
		gml_pragma("forceinline")
		
		return players[| _index]
	}
}