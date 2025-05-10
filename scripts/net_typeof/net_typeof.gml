enum NetDataTypes {
	UNDEFINED,
	REAL,
	NAN,
	INFINITY,
	STRING,
	ARRAY,
	BOOL,
	INT32,
	STRUCT,
}

/// @param {Any} value
/// @return {Enum.NetDataTypes}
function net_typeof(_value) {
	switch typeof(_value) {
		default:
		case "undefined": return NetDataTypes.UNDEFINED
		
		case "number":
			if is_nan(_value) {
				return NetDataTypes.NAN
			}
			
			if is_infinity(_value) {
				return NetDataTypes.INFINITY
			}
			
			return NetDataTypes.REAL
		
		case "string": return NetDataTypes.STRING
		case "array": return NetDataTypes.ARRAY
		case "bool": return NetDataTypes.BOOL
		case "int32": return NetDataTypes.INT32
		case "struct": return NetDataTypes.STRUCT
	}
}