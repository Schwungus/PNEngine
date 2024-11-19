enum LineBoxClip {
	INSIDE = 0,
	LEFT = 1,
	RIGHT = 2,
	BOTTOM = 4,
	TOP = 8,
}

function __line_in_rectangle_get_outcode(_x, _y, _x1, _y1, _x2, _y2) {
	gml_pragma("forceinline")
	
	var _code = LineBoxClip.INSIDE
	
	if _x < _x1 { // to the left of clip window
		_code |= LineBoxClip.LEFT
	} else if _x > _x2 { // to the right of clip window
		_code |= LineBoxClip.RIGHT
	}
	
	if _y < _y1 { // below the clip window
		_code |= LineBoxClip.BOTTOM
	} else if _y > _y2 { // above the clip window
		_code |= LineBoxClip.TOP
	}
	
	return _code
}

function line_in_rectangle(_lx1, _ly1, _lx2, _ly2, _x1, _y1, _x2, _y2) {
	// compute outcodes for P0, P1, and whatever point lies outside the clip rectangle
	var _out1 = __line_in_rectangle_get_outcode(_lx1, _ly1, _x1, _y1, _x2, _y2)
	var _out2 = __line_in_rectangle_get_outcode(_lx2, _ly2, _x1, _y1, _x2, _y2)
	
	while true {
		if not (_out1 | _out2) {
			// bitwise OR is 0: both points inside window; trivially accept and exit loop
			return true
		}
		
		if _out1 & _out2 {
			/* bitwise AND is not 0: both points share an outside zone (LEFT, RIGHT,
			   TOP, or BOTTOM), so both must be outside window; exit loop (accept is
			   false) */
			break
		}
		
		// failed both tests, so calculate the line segment to clip from an outside
		// point to an intersection with clip edge
		var _x, _y
		
		// At least one endpoint is outside the clip rectangle; pick it.
		var _out = _out2 > _out1 ? _out2 : _out1
		
		/* Now find the intersection point;
		   use formulas:
			   slope = (_ly2 - _ly1) / (_lx2 - _lx1)
			   x = _lx1 + (1 / slope) * (ym - _ly1), where ym is _y1 or _y2
			   y = _ly1 + slope * (xm - _lx1), where xm is _x1 or _x2
		   No need to worry about divide-by-zero because, in each case, the outcode
		   bit being tested guarantees the denominator is non-zero */
		var d = 1 / (_ly2 - _ly1)
		
		if _out & LineBoxClip.TOP { // point is above the clip window
			_x = _lx1 + (_lx2 - _lx1) * (_y2 - _ly1) * d
			_y = _y2
		} else if _out & LineBoxClip.BOTTOM { // point is below the clip window
			_x = _lx1 + (_lx2 - _lx1) * (_y1 - _ly1) * d
			_y = _y1
		} else {
			d = 1 / (_lx2 - _lx1)
			
			if _out & LineBoxClip.RIGHT { // point is to the right of clip window
				_y = _ly1 + (_ly2 - _ly1) * (_x2 - _lx1) * d
				_x = _x2
			} else {
				if _out & LineBoxClip.LEFT { // point is to the left of clip window
					_y = _ly1 + (_ly2 - _ly1) * (_x1 - _lx1) * d
					_x = _x1
				}
			}
		}
		
		// Now we move outside point to intersection point to clip
		// and get ready for next pass.
		if _out == _out1 {
			_lx1 = _x
			_ly1 = _y
			_out1 = __line_in_rectangle_get_outcode(_lx1, _ly1, _x1, _y1, _x2, _y2)
		} else {
			_lx2 = _x
			_ly2 = _y
			_out2 = __line_in_rectangle_get_outcode(_lx2, _ly2, _x1, _y1, _x2, _y2)
		}
	}
	
	return false
}