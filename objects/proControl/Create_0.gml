/// @feather ignore GM1017
/// @feather ignore GM1019

#region Scripting
with Catspeak {
#region Standard Library
	applyPreset(CatspeakPreset.TYPE, CatspeakPreset.ARRAY, CatspeakPreset.STRING, CatspeakPreset.STRUCT)
	
#region Debug
	addFunction(
		"current_time", function () {
			return current_time
		},
		
		"get_timer", get_timer
	)
	
	addConstant(
		"TYPE_NUMBER", "number",
		"TYPE_STRING", "string",
		"TYPE_ARRAY", "array",
		"TYPE_BOOL", "bool",
		"TYPE_INT32", "int32",
		"TYPE_INT64", "int64",
		"TYPE_UNDEFINED", "undefined",
		"TYPE_STRUCT", "struct"
	)
#endregion
	
#region Math
	addConstant(
		"PI", pi,
		"EPSILON", math_get_epsilon(),
		"MATRIX_PROJECTION", matrix_projection,
		"MATRIX_VIEW", matrix_view,
		"MATRIX_WORLD", matrix_world,
		"RNG_GAME", global.rng_game,
		"RNG_VISUAL", global.rng_visual,
	)
	
	addFunction(
		"round", round,
		"frac", frac,
		"abs", abs,
		"sign", sign,
		"floor", floor,
		"ceil", ceil,
		"min", min,
		"max", max,
		"mean", mean,
		"median", median,
		"lerp", lerp,
		"lerp_angle", lerp_angle,
		"lerp_smooth", lerp_smooth,
		"lerp_delta", lerp_delta,
		"lerp3", lerp3,
		"clamp", clamp,
		"exp", exp,
		"ln", ln,
		"power", power,
		"sqr", sqr,
		"sqrt", sqrt,
		"log2", log2,
		"log10", log10,
		"logn", logn,
		"arccos", arccos,
		"arcsin", arcsin,
		"arctan", arctan,
		"arctan2", arctan2,
		"cos", cos,
		"sin", sin,
		"tan", tan,
		"dcos", dcos,
		"dsin", dsin,
		"dtan", dtan,
		"darccos", darccos,
		"darcsin", darcsin,
		"darctan", darctan,
		"darctan2", darctan2,
		"degtorad", degtorad,
		"radtodeg", radtodeg,
		"point_direction", point_direction,
		"point_pitch", point_pitch,
		"point_distance", point_distance,
		"dot_product", dot_product,
		"dot_product_normalized", dot_product_normalized,
		"angle_difference", angle_difference,
		"lengthdir_x", lengthdir_x,
		"lengthdir_y", lengthdir_y
	)
	
	addFunction(
		"point_distance_3d", point_distance_3d,
		"dot_product_3d", dot_product_3d,
		"dot_product_3d_normalized", dot_product_3d_normalized,
		"cross_product_3d", cross_product_3d,
		"cross_product_3d_normalized", cross_product_3d_normalized,
		"lengthdir_3d", lengthdir_3d,
		"normal_vector_3d", normal_vector_3d,
		"unit_vector_3d", unit_vector_3d,
		"matrix_build", matrix_build,
		"matrix_multiply", matrix_multiply,
		"matrix_build_identity", matrix_build_identity,
		"matrix_build_lookat", matrix_build_lookat,
		"matrix_build_projection_ortho", matrix_build_projection_ortho,
		"matrix_build_projection_perspective", matrix_build_projection_perspective,
		"matrix_build_projection_perspective_fov", matrix_build_projection_perspective_fov,
		"matrix_transform_point", matrix_transform_point,
		
		"matrix_transform_normal", function (_matrix, _nx, _ny, _nz) {
			var _result = matrix_transform_vertex(_matrix, _nx, _ny, _nz, 0)
			var __nx = _result[0]
			var __ny = _result[1]
			var __nz = _result[2]
			var d = 1 / point_distance_3d(0, 0, 0, __nx, __ny, __nz)
			
			_result[0] *= d
			_result[1] *= d
			_result[2] *= d
			
			return _result
		},
		
		"matrix_get", matrix_get,
		"matrix_set", matrix_set,
		"matrix_world_reset", matrix_world_reset,
		"dq_build", dq_build,
		"dq_build_identity", dq_build_identity,
		"dq_lerp", dq_lerp,
		"dq_get_translation", dq_get_translation,
		"dq_transform_point", dq_transform_point,
		"dq_get_x", dq_get_x,
		"dq_get_y", dq_get_y,
		"dq_get_z", dq_get_z,
		"dq_multiply", dq_multiply,
		"dq_conjugate", dq_conjugate,
		"quat_build", quat_build,
		"quat_build_euler", quat_build_euler,
		"quat_dot", quat_dot,
		"quat_multiply", quat_multiply,
		
		"Quaternion", BBMOD_Quaternion,
		"DualQuaternion", BBMOD_DualQuaternion
	)
#endregion
	
#region Date and Time
		addFunction("date_datetime_string", date_datetime_string)
#endregion
	
#region Color
		addConstant(
			"AQUA", c_aqua,
			"BLACK", c_black,
			"BLUE", c_blue,
			"DARK_GRAY", c_dkgray,
			"FUCHSIA", c_fuchsia,
			"GRAY", c_grey,
			"GREEN", c_green,
			"LIME", c_lime,
			"LIGHT_GRAY", c_ltgrey,
			"MAROON", c_maroon,
			"NAVY", c_navy,
			"OLIVE", c_olive,
			"ORANGE", c_orange,
			"PURPLE", c_purple,
			"RED", c_red,
			"SILVER", c_silver,
			"TEAL", c_teal,
			"WHITE", c_white,
			"YELLOW", c_yellow,
			"AB_GREEN", C_AB_GREEN,
		)
		
		addFunction(
			"color_get_blue", color_get_blue,
			"color_get_green", color_get_green,
			"color_get_red", color_get_red,
			"color_get_hue", color_get_hue,
			"color_get_saturation", color_get_saturation,
			"color_get_value", color_get_value,
			"make_color_rgb", make_color_rgb,
			"make_color_hsv", make_color_hsv,
			"merge_color", merge_color
		)
#endregion
	
#region Rendering
		addConstant(
			"FA_LEFT", fa_left,
			"FA_CENTER", fa_center,
			"FA_RIGHT", fa_right,
			
			"FA_TOP", fa_top,
			"FA_MIDDLE", fa_middle,
			"FA_BOTTOM", fa_bottom,
			
			"BM_NORMAL", bm_normal,
			"BM_ADD", bm_add,
			"BM_SUBTRACT", bm_subtract,
			"BM_MAX", bm_max,
			
			"BM_ZERO", bm_zero,
			"BM_ONE", bm_one,
			"BM_SRC_COLOR", bm_src_color,
			"BM_INV_SRC_COLOR", bm_inv_src_color,
			"BM_SRC_ALPHA", bm_src_alpha,
			"BM_INV_SRC_ALPHA", bm_inv_src_alpha,
			"BM_DEST_ALPHA", bm_dest_alpha,
			"BM_INV_DEST_ALPHA", bm_inv_dest_alpha,
			"BM_DEST_COLOR", bm_dest_color,
			"BM_INV_DEST_COLOR", bm_inv_dest_color,
			"BM_SRC_ALPHA_SAT", bm_src_alpha_sat,
			
			"PR_POINT_LIST", pr_pointlist,
			"PR_LINE_LIST", pr_linelist,
			"PR_LINE_STRIP", pr_linestrip,
			"PR_TRIANGLE_LIST", pr_trianglelist,
			"PR_TRIANGLE_STRIP", pr_trianglestrip,
			"PR_TRIANGLE_FAN", pr_trianglefan,
		)
		
		addFunction(
			"gpu_get_depth", gpu_get_depth,
			"gpu_get_tex_filter", gpu_get_tex_filter,
			"gpu_get_tex_repeat", gpu_get_tex_repeat,
			"gpu_get_blendmode", gpu_get_blendmode,
			"gpu_get_blendmode_ext", gpu_get_blendmode_ext,
			"gpu_get_blendmode_ext_sepalpha", gpu_get_blendmode_ext_sepalpha,
			"gpu_get_blendmode_src", gpu_get_blendmode_src,
			"gpu_get_blendmode_dest", gpu_get_blendmode_dest,
			"gpu_get_blendmode_srcalpha", gpu_get_blendmode_srcalpha,
			"gpu_get_blendmode_destalpha", gpu_get_blendmode_destalpha,
			"gpu_get_scissor", gpu_get_scissor,
			
			"gpu_set_depth", gpu_set_depth,
			"gpu_set_tex_filter", gpu_set_tex_filter,
			"gpu_set_tex_repeat", gpu_set_tex_repeat,
			"gpu_set_blendmode", gpu_set_blendmode,
			"gpu_set_blendmode_ext", gpu_set_blendmode_ext,
			"gpu_set_blendmode_ext_sepalpha", gpu_set_blendmode_ext_sepalpha,
			"gpu_set_scissor", gpu_set_scissor,
			
			"draw_clear", draw_clear,
			"draw_clear_alpha", draw_clear_alpha,
			
			"draw_get_color", draw_get_color,
			"draw_get_alpha", draw_get_alpha,
			"draw_get_font", draw_get_font,
			"draw_get_halign", draw_get_halign,
			"draw_get_valign", draw_get_valign,
			
			"draw_set_color", draw_set_color,
			"draw_set_alpha", draw_set_alpha,
			"draw_set_font", draw_set_font,
			"draw_set_halign", draw_set_halign,
			"draw_set_valign", draw_set_valign,
			
			"draw_arrow", draw_arrow,
			"draw_circle", draw_circle,
			"draw_circle_color", draw_circle_color,
			"draw_ellipse", draw_ellipse,
			"draw_ellipse_color", draw_ellipse_color,
			"draw_line", draw_line,
			"draw_line_color", draw_line_color,
			"draw_line_width", draw_line_width,
			"draw_line_width_color", draw_line_width_color,
			"draw_point", draw_point,
			"draw_point_color", draw_point_color,
			"draw_rectangle", draw_rectangle,
			"draw_rectangle_color", draw_rectangle_color,
			"draw_roundrect", draw_roundrect,
			"draw_roundrect_color", draw_roundrect_color,
			"draw_roundrect_ext", draw_roundrect_ext,
			"draw_roundrect_color_ext", draw_roundrect_color_ext,
			"draw_triangle", draw_triangle,
			"draw_triangle_color", draw_triangle_color,
			
			"draw_text", draw_text,
			"draw_text_ext", draw_text_ext,
			"draw_text_color", draw_text_color,
			"draw_text_transformed", draw_text_transformed,
			"draw_text_ext_color", draw_text_ext_color,
			"draw_text_ext_transformed", draw_text_ext_transformed,
			"draw_text_transformed_color", draw_text_transformed_color,
			"draw_text_ext_transformed_color", draw_text_ext_transformed_color,
			
			"draw_primitive_begin", draw_primitive_begin,
			"draw_primitive_end", draw_primitive_end,
			"draw_vertex", draw_vertex,
			"draw_vertex_color", draw_vertex_color,
			
			"shader_reset", shader_reset,
			"draw_clear", draw_clear,
			"draw_clear_alpha", draw_clear_alpha,
			
			"screen_width", window_get_width,
			"screen_height", window_get_height
		)
#endregion
#endregion

#region PNEngine
#region Debug
	addFunction(
		"print", print,
		
		"show_error", function (_str) {
			show_error(_str, true)
		},
		
		"show_caption", show_caption,
		"force_type", force_type,
		"force_type_fallback", force_type_fallback,
		"method", catspeak_method
	)
#endregion
	
#region String
	addFunction(
		"string_localize", lexicon_text,
		"string_rich", scribble,
		"string_typist", scribble_typist,
		"string_input", string_input,
		"string_time", string_time
	)
#endregion
	
#region Assets
	addConstant(
		"IMAGES", global.images,
		"MATERIALS", global.materials,
		"MODELS", global.models,
		"ANIMATIONS", global.animations,
		"FONTS", global.fonts,
		"SOUNDS", global.sounds,
		"MUSIC", global.music,
	)
	
	addFunction(
		"ui_load", ui_load,
		"thing_load", thing_load,
		"transition_load", transition_load,
		
		"mod_get_version", function (_name) {
			/* GROSS HACK: Mod names become lower case on Linux.
						   Convert the given string to lower case for
						   compatibility. */
			var _mod = global.mods[? string_lower(_name)]
			
			if _mod == undefined {
				return undefined
			}
			
			return _mod.version
		},
		
		"mod_find_file", mod_find_file,
		"mod_find_folder", mod_find_folder,
		
		"json_load", function (_filename, _exclude = "") {
			return json_load(mod_find_file(_filename, _exclude))
		}
	)
#endregion
	
#region Players
	addConstant(
		"MAX_PLAYERS", INPUT_MAX_PLAYERS,
		
		"PS_INACTIVE", PlayerStatus.INACTIVE,
		"PS_READY", PlayerStatus.PENDING,
		"PS_ACTIVE", PlayerStatus.ACTIVE,
		
		"INPUT_INVERSE", PLAYER_INPUT_INVERSE,
		"INPUT_AIM_INVERSE", PLAYER_AIM_INVERSE,
		"INPUT_UP_DOWN", PlayerInputs.UP_DOWN,
		"INPUT_LEFT_RIGHT", PlayerInputs.LEFT_RIGHT,
		"INPUT_JUMP", PlayerInputs.JUMP,
		"INPUT_INTERACT", PlayerInputs.INTERACT,
		"INPUT_ATTACK", PlayerInputs.ATTACK,
		"INPUT_INVENTORY_UP", PlayerInputs.INVENTORY_UP,
		"INPUT_INVENTORY_LEFT", PlayerInputs.INVENTORY_LEFT,
		"INPUT_INVENTORY_DOWN", PlayerInputs.INVENTORY_DOWN,
		"INPUT_INVENTORY_RIGHT", PlayerInputs.INVENTORY_RIGHT,
		"INPUT_AIM", PlayerInputs.AIM,
		"INPUT_AIM_UP_DOWN", PlayerInputs.AIM_UP_DOWN,
		"INPUT_AIM_LEFT_RIGHT", PlayerInputs.AIM_LEFT_RIGHT,
		"INPUT_FORCE_UP_DOWN", PlayerInputs.FORCE_UP_DOWN,
		"INPUT_FORCE_LEFT_RIGHT", PlayerInputs.FORCE_LEFT_RIGHT,
	)
	
	addFunction(
		"player_get", function (_index) {
			return global.players[_index]
		},
		
		/*"players_ready", function () {
			return ds_list_size(global.players_ready)
		},
		
		"players_active", function () {
			return ds_list_size(global.players_active)
		},*/
		
		"player_binding_label", function (_verb, _index = 0) {
			return input_binding_get_name(input_binding_get(_verb, _index))
		}
	)
#endregion
	
#region Level
	var _flags = global.flags
	
	addConstant(
		"GLOBAL", _flags[FlagGroups.GLOBAL],
		"LOCAL", _flags[FlagGroups.LOCAL],
		"STATIC", _flags[FlagGroups.STATIC],
		
		"CP_LEVEL", 0,
		"CP_AREA", 1,
		"CP_TAG", 2
	)
	
	addFunction("checkpoint_get", function (_index) {
		return global.checkpoint[_index]
	})
#endregion
	
#region Things
	addConstant(
		"NO_THING", noone,
		"EVERY_THING", all,
		
		"TAG_PLAYERS", ThingTags.PLAYERS,
		"TAG_FRIENDS", ThingTags.FRIENDS,
		"TAG_ENEMIES", ThingTags.ENEMIES,
		"TAG_NONE", ThingTags.NONE,
		"TAG_ALL", ThingTags.ALL,
		
		"M_COLLISION_NONE", MCollision.NONE,
		"M_COLLISION_NORMAL", MCollision.NORMAL,
		"M_COLLISION_BOUNCE", MCollision.BOUNCE,
		"M_COLLISION_BULLET", MCollision.BULLET,
		
		"M_SHADOW_NONE", MShadow.NONE,
		"M_SHADOW_NORMAL", MShadow.NORMAL,
		"M_SHADOW_BONE", MShadow.BONE,
		"M_SHADOW_MODEL", MShadow.MODEL,
		
		"HSF_IGNORE_HOLDER", HitscanFlags.IGNORE_HOLDER,
		"HSF_IGNORE_MASTER", HitscanFlags.IGNORE_MASTER,
		
		"DMG_NONE", DamageResults.NONE,
		"DMG_HIT", DamageResults.HIT,
		"DMG_MISSED", DamageResults.MISSED,
		"DMG_BLOCKED", DamageResults.BLOCKED,
		"DMG_ABSORBED", DamageResults.ABSORBED,
		"DMG_DAMAGED", DamageResults.DAMAGED,
		"DMG_FATAL", DamageResults.FATAL,
		
		"CTARG_RANGE", CameraTargetData.RANGE,
		"CTARG_X_OFFSET", CameraTargetData.X_OFFSET,
		"CTARG_Y_OFFSET", CameraTargetData.Y_OFFSET,
		"CTARG_Z_OFFSET", CameraTargetData.Z_OFFSET,
		
		"CPOI_LERP", CameraPOIData.LERP,
		"CPOI_X_OFFSET", CameraTargetData.X_OFFSET,
		"CPOI_Y_OFFSET", CameraTargetData.Y_OFFSET,
		"CPOI_Z_OFFSET", CameraTargetData.Z_OFFSET,
		
		"CLERP_LINEAR", CameraLerpTypes.LINEAR,
		"CLERP_SMOOTH", CameraLerpTypes.SMOOTH,
		"CLERP_EASE_IN", CameraLerpTypes.EASE_IN,
		"CLERP_EASE_OUT", CameraLerpTypes.EASE_OUT
	)
	
	addFunction("thing_exists", instance_exists)
#endregion
	
#region Collision
	addConstant(
		"TRIANGLE_X1", TriangleData.X1,
		"TRIANGLE_Y1", TriangleData.Y1,
		"TRIANGLE_Z1", TriangleData.Z1,
		"TRIANGLE_X2", TriangleData.X2,
		"TRIANGLE_Y2", TriangleData.Y2,
		"TRIANGLE_Z2", TriangleData.Z2,
		"TRIANGLE_X3", TriangleData.X3,
		"TRIANGLE_Y3", TriangleData.Y3,
		"TRIANGLE_Z3", TriangleData.Z3,
		"TRIANGLE_NX", TriangleData.NX,
		"TRIANGLE_NY", TriangleData.NY,
		"TRIANGLE_NZ", TriangleData.NZ,
		"TRIANGLE_SURFACE", TriangleData.SURFACE,
		"TRIANGLE_FLAGS", TriangleData.FLAGS,
		"TRIANGLE_LAYERS", TriangleData.LAYERS,
		
		"CFLAG_BODY", CollisionFlags.BODY,
		"CFLAG_BULLET", CollisionFlags.BULLET,
		"CFLAG_VISION", CollisionFlags.VISION,
		"CFLAG_CAMERA", CollisionFlags.CAMERA,
		"CFLAG_SHADOW", CollisionFlags.SHADOW,
		"CFLAG_STICKY", CollisionFlags.STICKY,
		"CFLAG_SLIPPERY", CollisionFlags.SLIPPERY,
		"CFLAG_ALL", CollisionFlags.ALL,
		
		"CLAYER_0", CollisionLayers._0,
		"CLAYER_1", CollisionLayers._1,
		"CLAYER_2", CollisionLayers._2,
		"CLAYER_3", CollisionLayers._3,
		"CLAYER_4", CollisionLayers._4,
		"CLAYER_5", CollisionLayers._5,
		"CLAYER_6", CollisionLayers._6,
		"CLAYER_7", CollisionLayers._7,
		"CLAYER_ALL", CollisionLayers.ALL,
		
		"RAY_HIT", RaycastData.HIT,
		"RAY_X", RaycastData.X,
		"RAY_Y", RaycastData.Y,
		"RAY_Z", RaycastData.Z,
		"RAY_NX", RaycastData.NX,
		"RAY_NY", RaycastData.NY,
		"RAY_NZ", RaycastData.NZ,
		"RAY_SURFACE", RaycastData.SURFACE,
		"RAY_THING", RaycastData.THING,
		"RAY_TRIANGLE", RaycastData.TRIANGLE
	)
	
	addFunction("raycast_data_create", raycast_data_create)
#endregion
	
#region Rendering
	addConstant(
		"SH_SKY", global.sky_shader,
		"SH_BLOOM_PASS", global.bloom_pass_shader,
		"SH_BLOOM_UP", global.bloom_up_shader,
		"SH_BLOOM_DOWN", global.bloom_down_shader,
		"SH_CURVE", global.curve_shader,
		"SH_DEPTH", global.depth_shader,
		"SH_DITHER", global.dither_shader,
		"SH_BLEED", global.bleed_shader,
		
		"U_AMBIENT_COLOR", global.u_ambient_color,
		"U_COLOR", global.u_color,
		"U_FOG_DISTANCE", global.u_fog_distance,
		"U_FOG_COLOR", global.u_fog_color,
		"U_MATERIAL_ALPHA_TEST", global.u_material_alpha_test,
		"U_MATERIAL_BRIGHT", global.u_material_bright,
		"U_MATERIAL_COLOR", global.u_material_color,
		"U_MATERIAL_SCROLL", global.u_material_scroll,
		"U_MATERIAL_SPECULAR", global.u_material_specular,
		"U_MATERIAL_WIND", global.u_material_wind,
		"U_CURVE", global.u_curve,
		"U_LIGHT_DATA", global.u_light_data,
		"U_LIGHT_TEXTURE", global.u_light_texture,
		"U_LIGHT_UVS", global.u_light_uvs,
		"U_LIGHT_REPEAT", global.u_light_repeat,
		"U_DARK_COLOR", global.u_dark_color,
		"U_BLEED", global.u_bleed,
		
		"PART_DEAD", ParticleData.DEAD,
		"PART_IMAGE", ParticleData.IMAGE,
		"PART_FRAME", ParticleData.FRAME,
		"PART_FRAME_SPEED", ParticleData.FRAME_SPEED,
		"PART_ANIMATION", ParticleData.ANIMATION,
		"PART_ALPHA_TEST", ParticleData.ALPHA_TEST,
		"PART_WIDTH", ParticleData.WIDTH,
		"PART_WIDTH_SPEED", ParticleData.WIDTH_SPEED,
		"PART_HEIGHT", ParticleData.HEIGHT,
		"PART_HEIGHT_SPEED", ParticleData.HEIGHT_SPEED,
		"PART_FLAT", ParticleData.FLAT,
		"PART_ANGLE", ParticleData.ANGLE,
		"PART_ANGLE_SPEED", ParticleData.ANGLE_SPEED,
		"PART_PITCH", ParticleData.PITCH,
		"PART_PITCH_SPEED", ParticleData.PITCH_SPEED,
		"PART_ROLL", ParticleData.ROLL,
		"PART_ROLL_SPEED", ParticleData.ROLL_SPEED,
		"PART_COLOR", ParticleData.COLOR,
		"PART_ALPHA", ParticleData.ALPHA,
		"PART_ALPHA_SPEED", ParticleData.ALPHA_SPEED,
		"PART_BRIGHT", ParticleData.BRIGHT,
		"PART_BRIGHT_SPEED", ParticleData.BRIGHT_SPEED,
		"PART_BLENDMODE", ParticleData.BLENDMODE,
		"PART_TICKS", ParticleData.TICKS,
		"PART_X", ParticleData.X,
		"PART_Y", ParticleData.Y,
		"PART_Z", ParticleData.Z,
		"PART_FLOOR_Z", ParticleData.FLOOR_Z,
		"PART_CEILING_Z", ParticleData.CEILING_Z,
		"PART_X_SPEED", ParticleData.X_SPEED,
		"PART_Y_SPEED", ParticleData.Y_SPEED,
		"PART_Z_SPEED", ParticleData.Z_SPEED,
		"PART_X_FRICTION", ParticleData.X_FRICTION,
		"PART_Y_FRICTION", ParticleData.Y_FRICTION,
		"PART_Z_FRICTION", ParticleData.Z_FRICTION,
		"PART_GRAVITY", ParticleData.GRAVITY,
		"PART_MAX_FLY_SPEED", ParticleData.MAX_FLY_SPEED,
		"PART_MAX_FALL_SPEED", ParticleData.MAX_FALL_SPEED,
		
		"PANI_PLAY", ParticleAnimations.PLAY,
		"PANI_PLAY_STAY", ParticleAnimations.PLAY_STAY,
		"PANI_LOOP", ParticleAnimations.LOOP,
		
		"CANS_NO_DATA", CanvasStatus.NO_DATA,
		"CANS_IN_USE", CanvasStatus.IN_USE,
		"CANS_HAS_DATA", CanvasStatus.HAS_DATA,
		"CANS_HAS_DATA_CACHED", CanvasStatus.HAS_DATA_CACHED,
		
		"LIGHT_ACTIVE", LightData.ACTIVE,
		"LIGHT_TYPE", LightData.TYPE,
		"LIGHT_X", LightData.X,
		"LIGHT_Y", LightData.Y,
		"LIGHT_Z", LightData.Z,
		"LIGHT_ARG0", LightData.ARG0,
		"LIGHT_ARG1", LightData.ARG1,
		"LIGHT_ARG2", LightData.ARG2,
		"LIGHT_ARG3", LightData.ARG3,
		"LIGHT_ARG4", LightData.ARG4,
		"LIGHT_ARG5", LightData.ARG5,
		"LIGHT_RED", LightData.RED,
		"LIGHT_GREEN", LightData.GREEN,
		"LIGHT_BLUE", LightData.BLUE,
		"LIGHT_ALPHA", LightData.ALPHA,
		"LIGHT_SIZE", LightData.__SIZE,
		
		"LTYPE_NONE", LightTypes.NONE,
		"LTYPE_DIRECTIONAL", LightTypes.DIRECTIONAL,
		"LTYPE_POINT", LightTypes.POINT,
		"LTYPE_SPOT", LightTypes.SPOT,
		
		"MAX_LIGHTS", MAX_LIGHTS,
	)
	
	addFunction(
		"get_world_shader", function () {
			with global.config {
				return (vid_lighting.value or vid_antialias.value) ? global.world_pixel_shader : global.world_shader
			}
		},
		
		"vid_texture_filter", function () {
			return global.config.vid_texture_filter.value
		},
		
		"Canvas", Canvas,
		"screenshot_canvas", screenshot_canvas,
		"ModelInstance", ModelInstance,
		"interp", interp,
		"interp_skip", interp_skip,
		
		"shader_current", function () {
			return global.current_shader
		},
		
		"draw_image", CollageDrawImage,
		"draw_image_ext", CollageDrawImageExt,
		"draw_image_general", CollageDrawImageGeneral,
		"draw_image_stretched", CollageDrawImageStretched,
		"draw_image_stretched_ext", CollageDrawImageStretchedExt,
		"draw_image_part", CollageDrawImagePart,
		"draw_image_part_ext", CollageDrawImagePartExt,
		"draw_image_tiled", CollageDrawImageTiled,
		"draw_image_tiled_ext", CollageDrawImageTiledExt,
		
		"batch_billboard", batch_billboard,
		"batch_floor", batch_floor,
		"batch_floor_ext", batch_floor_ext,
		"batch_floor_angle", batch_floor_angle,
		"batch_wall", batch_wall,
		"batch_line", batch_line,
		"batch_trail", batch_trail,
		"batch_set_alpha_test", batch_set_alpha_test,
		"batch_set_bright", batch_set_bright,
		"batch_set_blendmode", batch_set_blendmode,
		"batch_set_properties", batch_set_properties
	)
#endregion
	
#region Audio
	addConstant(
		"MUSP_DEFAULT", MusicPriorities.DEFAULT,
		"MUSP_POWER", MusicPriorities.POWER,
		"MUSP_SCENE", MusicPriorities.SCENE,
		"MUSP_FANFARE", MusicPriorities.FANFARE,
	)
	
	addFunction(
		"music_play", music_play,
		
		"music_get_instance", function (_priority) {
			return global.music_instances[| _priority]
		},
		
		"music_stop_all", function (_fade) {
			var _music_instances = global.music_instances
			var i = ds_list_size(_music_instances)
			
			while i {
				_music_instances[| --i].stop(_fade)
			}
		},
		
		"music_gain_all", function (_gain, _time) {
			var _music_instances = global.music_instances
			var i = ds_list_size(_music_instances)
			
			while i {
				_music_instances[| --i].set_gain_common(3, _gain, _time)
			}
		},
		
		"sound_is_playing", function (_sound) {
			return fmod_channel_control_is_playing(_sound)
		},
		
		"sound_stop", function (_sound) {
			fmod_channel_control_stop(_sound)
		},
		
		"sound_get_pitch", function (_sound) {
			return fmod_channel_control_get_pitch(_sound)
		},
		
		"sound_set_pitch", function (_sound, _pitch) {
			fmod_channel_control_set_pitch(_sound, _pitch)
		}
	)
#endregion
	
#region Game
	addConstant(
		"GAME_DEFAULT", GameStatus.DEFAULT,
		"GAME_NETGAME", GameStatus.NETGAME,
		"GAME_DEMO", GameStatus.DEMO,
		
		"TICKRATE", TICKRATE,
		
		"TOPT_NEW_FILE", TitleOptions.NEW_FILE,
		"TOPT_LOAD_FILE", TitleOptions.LOAD_FILE,
		"TOPT_DELETE_FILE", TitleOptions.DELETE_FILE,
		"TOPT_OPTIONS", TitleOptions.OPTIONS
	)
	
	addFunction(
		"game_status", function () {
			return global.game_status
		},
		
		"game_master", function () {
			return not global.demo_client and net_master()
		},
		
		"delta_time", function () {
			return global.delta
		}
	)
#endregion
	
#region UI
	addConstant(
		"UINP_UP_DOWN", UIInputs.UP_DOWN,
		"UINP_LEFT_RIGHT", UIInputs.LEFT_RIGHT,
		"UINP_CONFIRM", UIInputs.CONFIRM,
		"UINP_BACK", UIInputs.BACK,
		"UINP_MOUSE_X", UIInputs.MOUSE_X,
		"UINP_MOUSE_Y", UIInputs.MOUSE_Y,
		"UINP_MOUSE_CONFIRM", UIInputs.MOUSE_CONFIRM
	)
	
	addFunction(
		"ui_create", function (_type, _special = undefined) {
			return ui_create(_type, _special, true)
		},
		
		"ui_exists", ui_exists,
		
		"ui_root", function () {
			return global.ui
		},
		
		"ui_top", function () {
			var _top = global.ui
			
			while _top != undefined {
				var _child = _top.child
				
				if _child == undefined {
					break
				}
				
				_top = _child
			}
			
			return _top
		}
	)
#endregion
#endregion
}
#endregion

global.ui_font = scribble_fallback_font
ui_font_name = ""
global.chat_font = scribble_fallback_font
global.chat_sound = undefined
global.switch_sound = undefined
global.select_sound = undefined
global.fail_sound = undefined
global.back_sound = undefined

var _custom_ui_font = undefined
var _custom_chat_font = undefined
var _custom_chat_sound = "sndChat"
var _custom_switch_sound = undefined
var _custom_select_sound = undefined
var _custom_fail_sound = undefined
var _custom_back_sound = undefined

#region Mods
var _mods = global.mods
var _disabled_mods = force_type_fallback(json_load(DATA_PATH + "disabled.json"), "array", [])
var n = array_length(_disabled_mods)
var _load_mods = []
var _loaded = 0
var _mod = file_find_first(DATA_PATH + "*", fa_directory)
	
while _mod != "" {
	if directory_exists(DATA_PATH + _mod) {
		var _enabled = true
		var i = 0
		
		repeat n {
			if _disabled_mods[i++] == _mod {
				print($"proControl: Mod '{_mod}' is disabled, skipping")
				_enabled = false
				
				break
			}
		}
		
		if _enabled {
			array_push(_load_mods, _mod);
			++_loaded
		}
	}
	
	_mod = file_find_next()
}

file_find_close()

var i = 0

repeat _loaded {
	new Mod(_load_mods[i++])
}

var _key = ds_map_find_first(_mods)
var _handlers = global.handlers

repeat ds_map_size(_mods) {
	_mod = _mods[? _key]
	
	// Failsafe for Linux
	if _mod == undefined {
		_key = ds_map_find_next(_mods, _key)
		
		continue
	}
	
	print($"proControl: Initializing '{_mod.name}'")
	
	var _path = _mod.path
	var _languages = _path + "languages/languages.json"
	
	if file_exists(_languages) {
		print($"proControl: Loading languages from '{_languages}'")
		lexicon_index_definitions(_languages)
	}
	
	var _defs = _path + "mod.json"
	var _info = json_load(_defs)
	
	if is_struct(_info) {
		print($"proControl: Loading properties from '{_defs}'")
		
		var _title = _info[$ "title"]
		
		if is_string(_title) {
			window_set_caption(_title)
		}
		
		var _version = _info[$ "version"]
		
		if is_string(_version) {
			_mod.version = _version
		}
		
		var _rpc_id = _info[$ "rpc"]
		
		if is_string(_rpc_id) {
			global.game_rpc_id = _rpc_id
		}
		
		var _handefs = _info[$ "handlers"]
		
		if is_array(_handefs) {
			var _scripts = global.scripts
			
			i = 0
			
			repeat array_length(_handefs) {
				var _hname = force_type(_handefs[i++], "string")
				var _handler_script = _scripts.fetch(_hname)
				
				if _handler_script != undefined and not ds_map_exists(_handlers, _hname) {
					_handler_script.transient = true
					
					var _handler = new Handler(_handler_script)
					
					_handlers[? _hname] = _handler
					
					with _handler {
						if on_register != undefined {
							catspeak_execute(on_register)
						}
					}
				}
			}
		}
		
		var _states = _info[$ "states"]
		
		if is_struct(_states) {
			var _default_states = global.default_states
			var _names = struct_get_names(_states)
			
			i = 0
			
			repeat struct_names_count(_states) {
				_key = _names[i]
				_default_states[? _key] = _states[$ _key];
				++i
			}
		}
		
		var _flags = _info[$ "flags"]
		
		if is_struct(_flags) {
			var _global = force_type_fallback(_flags[$ "global"], "struct")
			
			if is_struct(_global) {
				var _default_flags = global.default_flags
				var _names = struct_get_names(_global)
				
				i = 0
				
				repeat struct_names_count(_global) {
					_key = _names[i]
					_default_flags[? _key] = _global[$ _key];
					++i
				}
			}
			
			var _static = force_type_fallback(_flags[$ "static"], "struct")
			
			if is_struct(_static) {
				var _static_flags = global.flags[FlagGroups.STATIC].flags
				var _names = struct_get_names(_static)
				
				i = 0
				
				repeat struct_names_count(_static) {
					_key = _names[i]
					_static_flags[? _key] = _static[$ _key];
					++i
				}
			}
		}
		
		var _ui_font = _info[$ "ui_font"]
		
		if is_string(_ui_font) {
			_custom_ui_font = _ui_font
		}
		
		var _chat_font = _info[$ "chat_font"]
		
		if is_string(_chat_font) {
			_custom_chat_font = _chat_font
		}
		
		var _chat_sound = _info[$ "chat_sound"]
		
		if is_string(_chat_sound) {
			_custom_chat_sound = _chat_sound
		}
		
		var _switch_sound = _info[$ "switch_sound"]
		
		if is_string(_switch_sound) {
			_custom_switch_sound = _switch_sound
		}
		
		var _select_sound = _info[$ "select_sound"]
		
		if is_string(_select_sound) {
			_custom_select_sound = _select_sound
		}
		
		var _fail_sound = _info[$ "fail_sound"]
		
		if is_string(_fail_sound) {
			_custom_fail_sound = _fail_sound
		}
		
		var _back_sound = _info[$ "back_sound"]
		
		if is_string(_back_sound) {
			_custom_back_sound = _back_sound
		}
	}
	
	_key = ds_map_find_next(_mods, _key)
}
	
global.flags[FlagGroups.GLOBAL].clear()
_key = ds_map_find_first(_handlers)

repeat ds_map_size(_handlers) {
	with _handlers[? _key] {
		if on_start != undefined {
			catspeak_execute(on_start)
		}
	}
	
	_key = ds_map_find_next(_handlers, _key)
}
#endregion

#region Language
lexicon_index_fallback_language_set("English")
lexicon_language_set("English")

var _languages = lexicon_languages_get_array()
var _languages2 = array_create(n)

n = array_length(_languages)
i = 0

repeat n {
	_languages2[i] = _languages[i][0];
	++i
}

global.oui_values[OUIValues.LANGUAGE] = _languages2
#endregion

config_update()

var _players = global.players

i = 0

repeat INPUT_MAX_PLAYERS {
	_players[i++].clear_states()
}

#region Text
var _fonts = global.fonts

if is_string(_custom_ui_font) {
	var _font = _fonts.fetch(_custom_ui_font)
	
	global.ui_font = _font.font
	ui_font_name = _font.name
	_font.transient = true
}

if is_string(_custom_chat_font) {
	var _font = _fonts.fetch(_custom_chat_font)
	
	global.chat_font = _font.font
	_font.transient = true
}

global.chat_sound = global.sounds.fetch(_custom_chat_sound)
global.chat_sound.transient = true

if is_string(_custom_switch_sound) {
	global.switch_sound = global.sounds.fetch(_custom_switch_sound)
	global.switch_sound.transient = true
}

if is_string(_custom_select_sound) {
	global.select_sound = global.sounds.fetch(_custom_select_sound)
	global.select_sound.transient = true
}

if is_string(_custom_fail_sound) {
	global.fail_sound = global.sounds.fetch(_custom_fail_sound)
	global.fail_sound.transient = true
}

if is_string(_custom_back_sound) {
	global.back_sound = global.sounds.fetch(_custom_back_sound)
	global.back_sound.transient = true
}

caption = scribble("", "__PNENGINE_CAPTION__").starting_format(ui_font_name, c_white).align(fa_center, fa_bottom)
caption_time = -1
#endregion

#region Level
load_level = "lvlLogo"
load_area = 0
load_tag = ThingTags.NONE
load_state = LoadStates.START
#endregion

#region Discord
if not np_initdiscord(global.game_rpc_id, true, np_steam_app_id_empty) {
	print("! proControl: Could not initialize Discord Rich Presence")
}
#endregion

#region Input
mouse_dx = 0
mouse_dy = 0
#endregion