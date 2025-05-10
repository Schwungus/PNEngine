/// @func string_time(ticks)
/// @param {Real} ticks
/// @return {String}
function string_time(_ticks) {
	var _full_seconds = _ticks / TICKRATE
	var _full_minutes = _full_seconds * 0.0166666666666667
	var _full_hours = _full_minutes * 0.0166666666666667
	
	var _seconds = _full_seconds mod 60
	var _minutes = floor(_full_minutes % 60)
	var _hours = floor(_full_hours % 24)
	var _days = floor(_full_hours * 0.0416666666666667)
	
	var _timestamp = ""
	
	if _days > 0 {
		_timestamp += string_replace_all(string_format(_days, 2, 0), " ", "0") + ":"
	}
	
	if _hours > 0 or _days > 0 {
		_timestamp += string_replace_all(string_format(_hours, 2, 0), " ", "0") + ":" + string_replace_all(string_format(_minutes, 2, 0), " ", "0")
	} else {
		_timestamp += string(_minutes)
	}
	
	_timestamp += ":" + string_replace_all(string_format(_seconds, 2, 2), " ", "0")
	
	return _timestamp
}