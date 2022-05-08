/// @desc

#region Macro Defs

#macro HEADER obj_header
#macro CURRENT_FRAME global.g_currentframe
#macro CAMERA3D global.g_camera3d
#macro GRAPHICS global.g_graphics

#endregion

randomize();
printf("Randomseed: %s", random_get_seed());

CURRENT_FRAME = 0;
CAMERA3D = new Camera3D();
CAMERA3D.SetupCamera(480, 270, 50, 10, 1000);
lastwindowsize = [window_get_width(), window_get_height()];
windowresized = false;

GRAPHICS = instance_create_depth(x, y, 0, obj_graphics);
vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_color();
vertex_format_add_texcoord();
GRAPHICS.DefineFormat(vertex_format_end(), "color");

draw_set_font(fnt_cave);
display_set_gui_size(480, 270);

show_debug_overlay(1);

// VBFormats

// POS COL TEX
vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_color();
vertex_format_add_texcoord();
vbf_pct = vertex_format_end();

// POS NOR COL TEX
vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_normal();
vertex_format_add_color();
vertex_format_add_texcoord();
vbf_pnct = vertex_format_end();

// POS NOR COL TEX BON WEI
vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_normal();
vertex_format_add_color();
vertex_format_add_texcoord();
vertex_format_add_custom(vertex_type_float4, vertex_usage_texcoord); // Bone Indices
vertex_format_add_custom(vertex_type_float4, vertex_usage_texcoord); // Bone Weights
vbf_pnctbw = vertex_format_end();

var shd = shd_pct;
shd_pct_u_zoffset = shader_get_uniform(shd, "u_zoffset");

var shd = shd_pnctbw;
shd_pnctbw_u_matpose = shader_get_uniform(shd, "u_matpose");
shd_pnctbw_u_zoffset = shader_get_uniform(shd, "u_zoffset");
shd_pnctbw_u_normalsign = shader_get_uniform(shd, "u_normalsign");

var shd = shd_fighter;
shd_fighter_u_matpose = shader_get_uniform(shd, "u_matpose");
shd_fighter_u_zoffset = shader_get_uniform(shd, "u_zoffset");
shd_fighter_u_forwardsign = shader_get_uniform(shd, "u_forwardsign");
shd_fighter_u_tintcolor = shader_get_uniform(shd, "u_tintcolor");
shd_fighter_u_tintparam = shader_get_uniform(shd, "u_tintparam");
shd_fighter_u_matshear = shader_get_uniform(shd, "u_matshear");

// Input
playerinputcount = 2;
playerinput = [];
for (var i = 0; i < playerinputcount; i++)
{
	playerinput[i] = new InputManager();
}

var inp = playerinput[0];
inp.DefineInputKey(InputIndex.right, KeyCode.right);
inp.DefineInputKey(InputIndex.up, KeyCode.up);
inp.DefineInputKey(InputIndex.left, KeyCode.left);
inp.DefineInputKey(InputIndex.down, KeyCode.down);
inp.DefineInputKey(InputIndex.a, KeyCode.z);
inp.DefineInputKey(InputIndex.b, KeyCode.x);
inp.DefineInputKey(InputIndex.c, KeyCode.c);
inp.DefineInputKey(InputIndex.dash, KeyCode.space);
inp.DefineInputKey(InputIndex.start, KeyCode.enter);
inp.DefineInputKey(InputIndex.select, KeyCode.shift);

// Vertex buffers
vb_map = ds_map_create();
vbm_map = ds_map_create();

room_goto_next();
