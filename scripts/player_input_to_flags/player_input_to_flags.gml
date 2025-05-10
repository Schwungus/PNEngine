/// @param {Bool} jump
/// @param {Bool} interact
/// @param {Bool} attack
/// @param {Bool} inventory_1
/// @param {Bool} inventory_2
/// @param {Bool} inventory_3
/// @param {Bool} inventory_4
/// @param {Bool} aim
/// @return {Real}
function player_input_to_flags(_jump, _interact, _attack, _inv1, _inv2, _inv3, _inv4, _aim) {
	gml_pragma("forceinline")
	
	var _flags = 0
	
	if _jump { _flags |= PIFlags.JUMP }
	if _interact { _flags |= PIFlags.INTERACT }
	if _attack { _flags |= PIFlags.ATTACK }
	if _inv1 { _flags |= PIFlags.INVENTORY1 }
	if _inv2 { _flags |= PIFlags.INVENTORY2 }
	if _inv3 { _flags |= PIFlags.INVENTORY3 }
	if _inv4 { _flags |= PIFlags.INVENTORY4 }
	if _aim { _flags |= PIFlags.AIM }
	
	return _flags
}