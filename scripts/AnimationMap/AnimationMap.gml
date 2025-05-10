function AnimationMap() : AssetMap() constructor {
	/// @func load(name)
	/// @desc Loads an Animation from "animations/".
	///       Extensions: .bbanim
	/// @param {String} name Animation file name.
	/// @context AnimationMap
	static load = function (_name) {
		if ds_map_exists(assets, _name) {
			exit
		}
		
		var _bbanim_file = mod_find_file("animations/" + _name + ".bbanim")
		
		if _bbanim_file == "" {
			print($"! AnimationMap: '{_name}' not found")
			
			exit
		}
		
		var _buffer = buffer_load(_bbanim_file)
		var _has_minor_version = false
		
		// Header
		switch buffer_read(_buffer, buffer_string) {
			case "bbanim": break
			
			case "BBANIM":
				_has_minor_version = true
			break
			
			default:
				show_error($"!!! ModelMap.load: '{_name}' does not have BBANIM header", true)
		}
		
		// Major version
		var _major_version = buffer_read(_buffer, buffer_u8)
		
		if _major_version != 3 {
			show_error($"!!! ModelMap.load: '{_name}' has invalid BBMOD major version {_major_version}, expected 3", true)
		}
		
		// Minor version
		var _minor_version = 0
		
		if _has_minor_version {
			_minor_version = buffer_read(_buffer, buffer_u8)
			
			if _minor_version > 21 {
				show_error($"!!! ModelMap.load: '{_name}' has invalid BBMOD minor version {_minor_version}, expected range [3, 21]", true)
			}
		}
		
		// Properties
		var _spaces = buffer_read(_buffer, buffer_u8)
		var _duration = buffer_read(_buffer, buffer_f64)
		var _tps = buffer_read(_buffer, buffer_f64)
		
		var _node_count = buffer_read(_buffer, buffer_u32)
		var _node_size = _node_count * 8
		var _bone_count = buffer_read(_buffer, buffer_u32)
		var _bone_size = _bone_count * 8
		
		var _animation = new Animation()
		
		with _animation {
			name = _name
			spaces = _spaces
			duration = _duration
			frame_speed = _tps / TICKRATE
			
			nodes_amount = _node_count
			bones_amount = _bone_count
			
			var i = 0
			var j = 0
			
			if _spaces & BoneSpaces.PARENT {
				parent_frames = array_create(_duration)
				
				repeat _duration {
					var _frame = array_create(_node_size)
					
					j = 0
					
					repeat _node_size {
						_frame[j++] = buffer_read(_buffer, buffer_f32)
					}
					
					parent_frames[i++] = _frame
				}
			} else if _spaces & BoneSpaces.WORLD {
				world_frames = array_create(_duration)
				
				repeat _duration {
					var _frame = array_create(_node_size)
					
					j = 0
					
					repeat _node_size {
						_frame[j++] = buffer_read(_buffer, buffer_f32)
					}
					
					world_frames[i++] = _frame
				}
			} else if _spaces & BoneSpaces.BONE {
				bone_frames = array_create(_duration)
				
				repeat _duration {
					var _frame = array_create(_bone_size)
					
					j = 0
					
					repeat _bone_size {
						_frame[j++] = buffer_read(_buffer, buffer_f32)
					}
					
					bone_frames[i++] = _frame
				}
			}
		}
		
		buffer_delete(_buffer)
		ds_map_add(assets, _name, _animation)
		print($"AnimationMap: Added '{_name}'")
	}
}

global.animations = new AnimationMap()