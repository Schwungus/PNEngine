// INPUTPATCH: PNEngine verbs
function __InputConfigVerbs()
{
    enum INPUT_VERB
    {
		// Game
        UP,
        DOWN,
        LEFT,
        RIGHT,
		WALK,
		
		JUMP,
		INTERACT,
		ATTACK,
		
        INVENTORY1,
		INVENTORY2,
		INVENTORY3,
		INVENTORY4,
		
		AIM,
		AIM_UP,
		AIM_LEFT,
		AIM_DOWN,
		AIM_RIGHT,
		
		// UI
		UI_UP,
		UI_LEFT,
		UI_DOWN,
		UI_RIGHT,
		UI_ENTER,
		UI_CLICK,
		
		PAUSE,
		
		// Misc
		LEAVE,
		
		DEBUG_OVERLAY,
		DEBUG_FPS,
		DEBUG_CONSOLE,
		DEBUG_CONSOLE_SUBMIT,
		DEBUG_CONSOLE_PREVIOUS,
    }
    
    enum INPUT_CLUSTER
    {
        //Add your own clusters here!
        //Clusters are used for two-dimensional checkers (InputDirection() etc.)
        MOVE,
		AIM,
		UI_MOVE,
    }
    
	// INPUTPATCH: Flip A/B over on Switch. "if (not INPUT_ON_SWITCH)"
	//             PNEngine probably never ends up on Switch so meh
	InputDefineVerb(INPUT_VERB.UP, "up", "W", -gp_axislv);
	InputDefineVerb(INPUT_VERB.LEFT, "left", "A", -gp_axislh);
	InputDefineVerb(INPUT_VERB.DOWN, "down", "S", gp_axislv);
	InputDefineVerb(INPUT_VERB.RIGHT, "right", "D", gp_axislh);
	InputDefineVerb(INPUT_VERB.WALK, "walk", vk_lcontrol, undefined);
	
	InputDefineVerb(INPUT_VERB.JUMP, "jump", vk_space, gp_face1);
	InputDefineVerb(INPUT_VERB.INTERACT, "interact", "E", gp_face2);
	InputDefineVerb(INPUT_VERB.ATTACK, "attack", [vk_period, mb_left], gp_shoulderr);
	
	InputDefineVerb(INPUT_VERB.INVENTORY1, "inventory1", vk_lshift, gp_shoulderlb);
	InputDefineVerb(INPUT_VERB.INVENTORY2, "inventory2", "1", gp_padl);
	InputDefineVerb(INPUT_VERB.INVENTORY3, "inventory3", "F", gp_padd);
	InputDefineVerb(INPUT_VERB.INVENTORY4, "inventory4", "2", gp_padr);
	
	InputDefineVerb(INPUT_VERB.AIM, "aim", [vk_comma, mb_right], gp_shoulderl);
	InputDefineVerb(INPUT_VERB.AIM_UP, "aim_up", vk_up, -gp_axisrv);
	InputDefineVerb(INPUT_VERB.AIM_LEFT, "aim_left", vk_left, -gp_axisrh);
	InputDefineVerb(INPUT_VERB.AIM_DOWN, "aim_down", vk_down, gp_axisrv);
	InputDefineVerb(INPUT_VERB.AIM_RIGHT, "aim_right", vk_right, gp_axisrh);
	
	InputDefineVerb(INPUT_VERB.UI_UP, "ui_up", [vk_up, "W"], [-gp_axislv, gp_padu]);
	InputDefineVerb(INPUT_VERB.UI_DOWN, "ui_down", [vk_down, "S"], [gp_axislv, gp_padd]);
	InputDefineVerb(INPUT_VERB.UI_LEFT, "ui_left", [vk_left, "A"], [-gp_axislh, gp_padl]);
	InputDefineVerb(INPUT_VERB.UI_RIGHT, "ui_right", [vk_right, "D"], [gp_axislh, gp_padr]);
	InputDefineVerb(INPUT_VERB.UI_ENTER, "ui_enter", [vk_enter, vk_space], gp_face1);
	InputDefineVerb(INPUT_VERB.UI_CLICK, "ui_click", mb_left, gp_face1);
	
	InputDefineVerb(INPUT_VERB.PAUSE, "pause", vk_escape, gp_start);
	InputDefineVerb(INPUT_VERB.LEAVE, "leave", vk_backspace, gp_select);
	
	InputDefineVerb(INPUT_VERB.DEBUG_OVERLAY, "debug_overlay", vk_f1, undefined);
	InputDefineVerb(INPUT_VERB.DEBUG_FPS, "debug_fps", vk_f2, undefined);
	InputDefineVerb(INPUT_VERB.DEBUG_CONSOLE, "debug_console", vk_backtick, undefined);
	InputDefineVerb(INPUT_VERB.DEBUG_CONSOLE_PREVIOUS, "debug_console_previous", vk_up, undefined);
	InputDefineVerb(INPUT_VERB.DEBUG_CONSOLE_SUBMIT, "debug_console_submit", vk_enter, undefined);
    
    //Define a cluster of verbs for moving around
    InputDefineCluster(INPUT_CLUSTER.MOVE, INPUT_VERB.UP, INPUT_VERB.RIGHT, INPUT_VERB.DOWN, INPUT_VERB.LEFT);
	InputDefineCluster(INPUT_CLUSTER.AIM, INPUT_VERB.AIM_UP, INPUT_VERB.AIM_RIGHT, INPUT_VERB.AIM_DOWN, INPUT_VERB.AIM_LEFT);
	InputDefineCluster(INPUT_CLUSTER.UI_MOVE, INPUT_VERB.UI_UP, INPUT_VERB.UI_RIGHT, INPUT_VERB.UI_DOWN, INPUT_VERB.UI_LEFT);
}