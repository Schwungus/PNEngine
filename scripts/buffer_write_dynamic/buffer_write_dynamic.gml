function buffer_write_dynamic(_buffer, _value) {
	var _type = net_typeof(_value)
	
	buffer_write(_buffer, buffer_u8, _type)
	
	switch _type {
		case NetDataTypes.REAL: buffer_write(_buffer, buffer_f32, _value) break
		case NetDataTypes.INFINITY: buffer_write(_buffer, buffer_bool, _value < 0) break
		case NetDataTypes.STRING: buffer_write(_buffer, buffer_string, _value) break
		
		case NetDataTypes.ARRAY: {
			var n = array_length(_value)
			
			buffer_write(_buffer, buffer_u32, n)
			
			var i = 0
			
			repeat n {
				var _val = _value[i++]
				
				buffer_write_dynamic(_buffer, _val)
			}
			
			break
		}
		
		case NetDataTypes.BOOL: buffer_write(_buffer, buffer_bool, _value) break
		case NetDataTypes.INT32: buffer_write(_buffer, buffer_s32, _value) break
		
		case NetDataTypes.STRUCT: {
			var _keys = struct_get_names(_value)
			var n = struct_names_count(_value)
			
			buffer_write(_buffer, buffer_u32, n)
			
			var i = 0
			
			repeat n {
				var _key = _keys[i++]
				var _val = _value[$ _key]
				
				buffer_write(_buffer, buffer_string, _key)
				buffer_write_dynamic(_buffer, _val);
			}
			
			break
		}
	}
}