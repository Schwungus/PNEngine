/// @func ui_exists(ui)
/// @param {Struct.UI} ui
/// @return {Bool}
function ui_exists(_ui) {
	gml_pragma("forceinline")
	
	return is_instanceof(_ui, UI) and _ui.exists
}