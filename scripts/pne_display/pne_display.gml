#macro COLOR_INVERSE 0.003921568627451 // 1/255

#region Colors
#macro C_AB_GREEN 0x00F000
#endregion

#region Display
application_surface_enable(false)
application_surface_draw_enable(false)
surface_free(application_surface)
display_set_gui_size(480, 270)

global.gui_priority = ds_priority_create()
global.transition_canvas = (new Canvas(1, 1)).SetDepthDisabled(true)
#endregion

#region Rendering
enum Canvases {
	WORLD,
	RENDER,
	DEPTH,
	__SIZE,
}

var _canvases = array_create(Canvases.__SIZE)

_canvases[Canvases.WORLD] = new Canvas(480, 270)
_canvases[Canvases.RENDER] = (new Canvas(480, 270)).SetDepthDisabled(true)
_canvases[Canvases.DEPTH] = (new Canvas(480, 270, false, surface_r8unorm)).SetDepthDisabled(true)
global.canvases = _canvases
global.bloom = new Bloom(160, 90, 3)
gpu_set_ztestenable(true)
gpu_set_zwriteenable(true)
global.current_shader = undefined
#endregion

#region Cameras
global.camera_active = noone
global.camera_demo = noone
global.camera_man = noone
global.camera_man_freeze = true

global.camera_layer = 0
global.camera_sort = ds_priority_create()
global.camera_shadows = ds_stack_create()
#endregion

#region Vertex Buffers
vertex_format_begin()
vertex_format_add_position_3d() // 3 * 4 (f32)
vertex_format_add_normal() // 3 * 4 (f32)
vertex_format_add_texcoord() // 2 * 4 (f32)
vertex_format_add_texcoord() // 2 * 4 (f32)
vertex_format_add_colour() // 1 * 4 (u8)
vertex_format_add_custom(vertex_type_float4, vertex_usage_texcoord) // 4 * 4 (f32)
vertex_format_add_custom(vertex_type_float4, vertex_usage_texcoord) // 4 * 4 (f32)
global.vbo_format = vertex_format_end()
#endregion

#region Batch Rendering
global.batch_vbo = vertex_create_buffer()
global.batch_matrix = matrix_build_identity()
global.batch_camera = noone
global.blank_mipmap = [0, 0, 1, 1]
global.batch_texture = undefined
global.batch_alpha_test = 0
global.batch_bright = 0
global.batch_blendmode = bm_normal
global.batch_filter = true
vertex_begin(global.batch_vbo, global.vbo_format)
#endregion

#region Particles
#macro MAX_PARTICLES 160

enum ParticleAnimations {
	PLAY,
	PLAY_STAY,
	LOOP,
}

enum ParticleData {
	DEAD,
	IMAGE,
	FRAME,
	FRAME_SPEED,
	ANIMATION,
	ALPHA_TEST,
	FILTER,
	WIDTH,
	WIDTH_SPEED,
	HEIGHT,
	HEIGHT_SPEED,
	FLAT,
	ANGLE,
	ANGLE_SPEED,
	PITCH,
	PITCH_SPEED,
	ROLL,
	ROLL_SPEED,
	COLOR,
	ALPHA,
	ALPHA_SPEED,
	BRIGHT,
	BRIGHT_SPEED,
	BLENDMODE,
	TICKS,
	X,
	Y,
	Z,
	FLOOR_Z,
	CEILING_Z,
	X_SPEED,
	Y_SPEED,
	Z_SPEED,
	X_FRICTION,
	Y_FRICTION,
	Z_FRICTION,
	GRAVITY,
	MAX_FLY_SPEED,
	MAX_FALL_SPEED,
	__SIZE,
}

global.dead_particles = ds_stack_create()
#endregion