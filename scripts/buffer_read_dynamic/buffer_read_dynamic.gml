function buffer_read_dynamic(_buffer) {
	switch buffer_read(_buffer, buffer_u8) {
		default:
		case NetDataTypes.UNDEFINED: return undefined
		case NetDataTypes.REAL: return buffer_read(_buffer, buffer_f32)
		case NetDataTypes.NAN: return NaN
		case NetDataTypes.INFINITY: return buffer_read(_buffer, buffer_bool) ? -infinity : infinity
		case NetDataTypes.STRING: return buffer_read(_buffer, buffer_string)
		
		case NetDataTypes.ARRAY: {
			var n = buffer_read(_buffer, buffer_u32)
			var _array = array_create(n)
			var i = 0
			
			repeat n {
				var _val = buffer_read_dynamic(_buffer)
				
				_array[i++] = _val
			}
			
			return _array
		}
		
		case NetDataTypes.BOOL: return buffer_read(_buffer, buffer_bool)
		case NetDataTypes.INT32: return buffer_read(_buffer, buffer_s32)
		
		case NetDataTypes.STRUCT: {
			var _struct = {}
			var n = buffer_read(_buffer, buffer_u32)
			
			repeat n {
				var _key = buffer_read(_buffer, buffer_string)
				var _val = buffer_read_dynamic(_buffer)
				
				_struct[$ _key] = _val
			}
			
			return _struct
		}
	}
}