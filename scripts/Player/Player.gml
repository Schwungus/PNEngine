function Player() constructor {
	slot = -1
	status = PlayerStatus.INACTIVE
	
	// Area
	level = undefined
	area = undefined
	thing = noone
	camera = noone
	
	// State
	states = ds_map_create()
	
	// Input
	input = array_create(PlayerInputs.__SIZE, 0)
	input_previous = array_create(PlayerInputs.__SIZE, 0)
	__show_reconnect_caption = true
	
	static respawn = function () {
		if status != PlayerStatus.ACTIVE or area == undefined {
			return noone
		}
		
		var _type = force_type(global.local_flags.get("player_class") ?? (global.global_flags.get("player_class") ?? get_state("player_class")), "string")
		var _spawn = noone
		
		// Pick a spawn furthest from all players.
		var _pawns = area.find_tag(ThingTags.PLAYERS)
		var n = array_length(_pawns)
		
		if n {
			var _x = 0
			var _y = 0
			var _z = 0
			var i = 0
			
			repeat n {
				with _pawns[i++] {
					_x += x
					_y += y
					_z += z
				}
			}
			
			var _inv = 1 / n
			
			_x *= _inv
			_y *= _inv
			_z *= _inv
			_spawn = area.furthest(_x, _y, _z, PlayerSpawn)
		} else {
			// There are no players in this level, pick a random spawn.
			var _spawns = area.find_tag(ThingTags.PLAYER_SPAWNS)
			
			n = array_length(_spawns)
			
			if n {
				_spawn = _spawns[global.rng_game.int(n - 1)]
			}
		}
		
		if thing_exists(_spawn) {
			var _player_pawn = noone
			
			with _spawn {
				_player_pawn = area.add(_type, x, y, z, angle, tag, special)
				
				if not thing_exists(_player_pawn) {
					return noone
				}
				
				var _player = other
				
				with _player_pawn {
					if not is_ancestor(PlayerPawn) {
						destroy(false)
						
						return noone
					}
					
					player = _player
					input = _player.input
					input_previous = _player.input_previous
					
					if instance_exists(camera) {
						camera.player = _player
					}
					
					catspeak_execute(player_create)
				}
			}
			
			if thing_exists(_player_pawn) {
				var _respawned = false
				
				if thing_exists(thing) {
					thing.destroy(false)
					_respawned = true
				}
				
				thing = _player_pawn
				
				if thing_exists(camera) {
					camera.destroy(false)
				}
				
				camera = _player_pawn.camera
				
				with camera {
					yaw = _player_pawn.angle
					pitch = 15
					interp_skip("syaw")
					interp_skip("spitch")
				}
				
				if _respawned {
					catspeak_execute_ext(_player_pawn.player_respawned, _player_pawn)
				}
				
				return _player_pawn
			}
		}
		
		return noone
	}
	
	static set_area = function (_id, _tag = ThingTags.NONE) {
		/* Move away from the current area.
		
		   If this player was the master of the area, the smallest indexed
		   player will become the next one. Otherwise the master will be
		   undefined and the area will stop ticking. */
		
		var _current_area = area
		
		if _current_area != undefined {
			var _active_things = _current_area.active_things
			var i = ds_list_size(_active_things)
			
			while i {
				var _thing = _active_things[| --i]
				
				if thing_exists(_thing) {
					_thing.player_left(self)
				}
			}
			
			if thing_exists(thing) {
				thing.destroy(false)
			}
			
			var _players_in_area = _current_area.players
			
			ds_list_delete(_players_in_area, ds_list_find_index(_players_in_area, self))
			
			if _current_area.master == self {
				i = 0
				
				repeat ds_list_size(_players_in_area) {
					var _player = _players_in_area[| i++]
					
					if _player.status == PlayerStatus.ACTIVE {
						_current_area.master = _player
						
						break
					}
				}
			}
			
			area_deactivate(_current_area)
		}
		
		/* Move to the new area.
		   If this area is inactive, the first player to enter it will become
		   responsible for ticking. */
		if level != undefined {
			area = level.areas[? _id]
			
			if area != undefined {
				with area {
					var _newcomer = other
					
					master ??= _newcomer
					ds_list_add(players, _newcomer)
					area_activate(self)
					_newcomer.respawn()
					
					var i = ds_list_size(active_things)
					
					while i {
						var _thing = active_things[| --i]
						
						_thing.player_entered(_newcomer)
					}
					
					var _pawn = _newcomer.thing
					
					if thing_exists(_pawn) {
						var _entrances = find_tag(_tag)
						
						if array_length(_entrances) {
							_pawn.enter_from(_entrances[0])
						}
					}
				}
			}
		} else {
			area = undefined
		}
		
		var _player = self
		var _area = area
		
		HANDLER_FOREACH_START
			if area_changed != undefined {
				catspeak_execute(area_changed, _player, _area)
			}
		HANDLER_FOREACH_END
		
		return true
	}
	
	static get_state = function (_key) {
		return states[? _key]
	}
	
	static set_state = function (_key, _value) {
		states[? _key] = _value
		
		return true
	}
	
	static reset_state = function (_key) {
		var _default = global.default_states[? _key]
		
		states[? _key] = _default
		
		return _default
	}
	
	static clear_states = function () {
		ds_map_clear(states)
		states[? "invincible"] = false
		states[? "frozen"] = false
		states[? "hud"] = true
		
		var _default_states = global.default_states
		var _key = ds_map_find_first(_default_states)
		
		repeat ds_map_size(_default_states) {
			states[? _key] = _default_states[? _key]
			_key = ds_map_find_next(_default_states, _key)
		}
		
		return true
	}
	
	static write_states = function (_buffer) {
		var n = ds_map_size(states)
		
		buffer_write(_buffer, buffer_u32, n)
		
		var _key = ds_map_find_first(states)
		
		repeat n {
			buffer_write(_buffer, buffer_string, _key)
			buffer_write_dynamic(_buffer, states[? _key])
			_key = ds_map_find_next(states, _key)
		}
	}
	
	static read_states = function (_buffer) {
		clear_states()
		
		var n = buffer_read(_buffer, buffer_u32)
		
		repeat n {
			var _key = buffer_read(_buffer, buffer_string)
			var _value = buffer_read_dynamic(_buffer)
			
			states[? _key] = _value
		}
	}
	
	static is_local = function () {
		gml_pragma("forceinline")
		
		return true
	}
	
	static get_name = function () {
		gml_pragma("forceinline")
		
		return $"Player {-~slot}"
	}
}