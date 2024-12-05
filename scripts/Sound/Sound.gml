function Sound() : Asset() constructor {
	asset = undefined
	
	pitch_high = 1
	pitch_low = 1
	
	static destroy = function () {
		if is_array(asset) {
			var i = array_length(asset)
			
			while i {
				fmod_sound_release(asset[--i])
			}
		} else {
			fmod_sound_release(asset)
		}
	}
}