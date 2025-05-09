function UI(_ui_script) constructor {
	exists = true
	ui_script = _ui_script
	
	load = undefined
	create = undefined
	clean_up = undefined
	tick = undefined
	draw_gui = undefined
	
	if _ui_script != undefined {
		load = _ui_script[$ "load"]
		create = _ui_script[$ "create"]
		clean_up = _ui_script[$ "clean_up"]
		tick = _ui_script[$ "tick"]
		draw_gui = _ui_script[$ "draw_gui"]
	}
	
	parent = undefined
	child = undefined
	special = undefined
	
	input = global.ui_input
	
	f_blocking = true
	f_block_input = false
	f_draw_screen = true
	
	/// @func destroy()
	/// @desc Destroys the UI.
	/// @return {Bool} Successful or not.
	/// @context UI
	static destroy = function () {
		if not exists {
			return false
		}
		
		if ui_exists(parent) {
			parent.child = undefined
		}
		
		if ui_exists(child) {
			child.destroy()
			child = undefined
		}
		
		if clean_up != undefined {
			catspeak_execute(clean_up)
		}
		
		if global.ui == self {
			global.ui = undefined
			
			if not global.console {
				fmod_channel_control_set_paused(global.world_channel_group, false)
			}
		}
		
		exists = false
		
		return true
	}
	
	/// @func link(type, [special])
	/// @desc Creates a new UI and links it as a child.
	/// @param {Function.UI|String} type UI type.
	/// @param {Any} [special] Custom properties for special behaviour.
	/// @return {Struct.UI|Undefined} New UI (undefined if unsuccessful).
	/// @context UI
	static link = function (_type, _special = undefined) {
		gml_pragma("forceinline")
		
		if ui_exists(child) {
			child.destroy()
		}
		
		var _ui = ui_create(_type, _special, false)
		
		if ui_exists(_ui) {
			child = _ui
			_ui.parent = self
		}
		
		return _ui
	}
	
	/// @func replace(type, [special])
	/// @desc Replaces the calling UI with a new UI.
	/// @param {Function.UI|String} type UI type.
	/// @param {Any} [special] Custom properties for special behaviour.
	/// @return {Struct.UI|Undefined} New UI (undefined if unsuccessful).
	/// @context UI
	static replace = function (_type, _special = undefined) {
		gml_pragma("forceinline")
		
		return ui_exists(parent) ? parent.link(_type) : ui_create(_type, _special, global.ui == self)
	}
	
	/// @func is_ancestor(type)
	/// @desc Checks if the UI type or family tree matches.
	/// @param {Function.UI|String} type UI type.
	/// @return {Bool}
	/// @context UI
	static is_ancestor = function (_type) {
		if is_string(_type) {
			return ui_script != undefined and ui_script.is_ancestor(_type)
		}
		
		return is_instanceof(self, _type)
	}
	
	/// @func play_sound(sound, [loop], [offset], [pitch])
	/// @desc Plays a sound in the UI scope.
	/// @param {Struct.Sound|Array<Struct.Sound>} sound Sound to play.
	/// @param {Bool} loop Whether to loop or not.
	/// @param {Real} offset Starting position in samples.
	/// @param {Real} pitch Base pitch.
	/// @return {Real|Undefined} Sound instance handle (undefined if unsuccessful).
	/// @context UI
	static play_sound = function (_sound, _loop = false, _offset = 0, _pitch = 1) {
		gml_pragma("forceinline")
		
		return global.ui_sounds.play(_sound, _loop, _offset, _pitch)
	}
	
	/// @func open_options()
	/// @desc Opens the hardcoded options menu.
	/// @return {Struct.UI|Undefined} New UI (undefined if unsuccessful).
	/// @context UI
	static open_options = function () {
		gml_pragma("forceinline")
		
		return link(proOptionsUI)
	}
	
	/// @func goto(level, [area], [tag], [transition])
	/// @desc Moves to another level.
	/// @param {String|Undefined} level Level name. Set to undefined to close the game.
	/// @param {Real} area Area ID.
	/// @param {Real|Enum.ThingTags} tag Thing tag to use for entrance points.
	/// @param {Asset.GMObject|String} transition Transition type.
	/// @context UI
	static goto = function (_level, _area = 0, _tag = ThingTags.NONE, _transition = noone) {
		var _inject = false
		
		// UIs are non-deterministic!!!
		// Do some workarounds for demos and netgames.
		if global.demo_buffer != undefined {
			// Clear the UI, assuming that the following tick buffer contains a
			// level packet.
			while global.ui != undefined {
				global.ui.destroy()
			}
			
			if global.demo_write {
				_inject = true
			} else {
				exit
			}
		}
		
		if _inject {
			var _tick_buffer = inject_tick_packet()
			
			buffer_write(_tick_buffer, buffer_u8, TickPackets.LEVEL)
			buffer_write(_tick_buffer, buffer_string, _level)
			buffer_write(_tick_buffer, buffer_u32, _area)
			buffer_write(_tick_buffer, buffer_s32, _tag)
			
			exit
		}
		
		global.level.goto(_level, _area, _tag, _transition)
	}
	
	/// @func leave(level, [area], [tag], [transition])
	/// @desc Safely leave the game to another level.
	///       This will end demo recording and disconnect from netgames.
	/// @param {String|Undefined} level Level name. Set to undefined to close the game.
	/// @param {Real} area Area ID.
	/// @param {Real|Enum.ThingTags} tag Thing tag to use for entrance points.
	/// @param {Asset.GMObject|String} transition Transition type.
	/// @context UI
	static leave = function (_level, _area = 0, _tag = ThingTags.NONE, _transition = noone) {
		// This is a safe method for leaving the game, i.e. ending
		// demos/disconnecting.
		if global.demo_buffer != undefined {
			if global.demo_write {
				var _filename = "demo_" + string_replace_all(date_datetime_string(date_current_datetime()), "/", ".")
				
				cmd_dend(_filename)
				show_caption($"[c_red]Demo ended prematurely. Saved as '{_filename}.pnd'.")
			} else {
				cmd_dend("")
			}
		}
		
		global.level.goto(_level, _area, _tag, _transition)
	}
	
	/// @func send_signal(name, [args...])
	/// @desc Writes a signal to the tick buffer for processing via Handlers.
	///       This allows the UI to deterministically interact with the level.
	/// @param {String} name Signal name.
	/// @param {Any} [args...] Arguments for special behaviour.
	/// @context UI
	static send_signal = function (_name) {
		if global.demo_buffer != undefined and not global.demo_write {
			exit
		}
		
		var _tick_buffer = inject_tick_packet()
		
		buffer_write(_tick_buffer, buffer_u8, TickPackets.SIGNAL)
		buffer_write(_tick_buffer, buffer_u8, 0) // Player slot (Always player 1 in local)
		buffer_write(_tick_buffer, buffer_string, _name)
		
		var _argc = argument_count - 1
		
		buffer_write(_tick_buffer, buffer_u8, _argc)
		
		var i = 1
		
		repeat _argc {
			buffer_write_dynamic(_tick_buffer, argument[i++])
		}
	}
}