#macro HANDLER_FOREACH_START var _handlers = global.handlers;\
var _key = ds_map_find_first(_handlers)\
\
repeat ds_map_size(_handlers) {\
	with _handlers[? _key] {

#macro HANDLER_FOREACH_END	}\
	\
	_key = ds_map_find_next(_handlers, _key)\
}

global.handlers = ds_map_create()