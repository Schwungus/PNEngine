function string_device(_player_index) {
	var _device = InputPlayerGetDevice(_player_index)
	
	switch _device {
		case INPUT_NO_DEVICE: _device = "No Device" break
		case INPUT_GENERIC_DEVICE: _device = "Generic" break
		case INPUT_KBM: _device = "Keyboard and Mouse" break
		case INPUT_TOUCH: _device = "Touch" break
		
		default: {
			if not InputDeviceIsGamepad(_device) {
				_device = "Unknown"
				
				break
			}
			
			switch InputDeviceGetGamepadType(_device) {
				default: _device = "Unknown" break
				case INPUT_GAMEPAD_TYPE_JOYCON_LEFT: _device = "Left Joycon" break
				case INPUT_GAMEPAD_TYPE_JOYCON_RIGHT: _device = "Right Joycon" break
				case INPUT_GAMEPAD_TYPE_PS4: _device = "PlayStation 4" break
				case INPUT_GAMEPAD_TYPE_PS5: _device = "PlayStation 5" break
				case INPUT_GAMEPAD_TYPE_SWITCH: _device = "Switch Pro" break
				case INPUT_GAMEPAD_TYPE_XBOX: _device = "Xbox" break
				case INPUT_GAMEPAD_TYPE_UNKNOWN: _device = "Other" break
			}
		}
	}
	
	return _device
}