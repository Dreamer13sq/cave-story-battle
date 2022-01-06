/// @desc

#region Macro Defs

#macro HEADER obj_header
#macro CURRENT_FRAME global.g_currentframe
#macro CAMERA3D global.g_camera3d

#endregion

CURRENT_FRAME = 0;
CAMERA3D = new Camera3D();
CAMERA3D.SetupCamera(480, 270, 50, 0.1, 100);

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

shd_pnctbw_u_matpose = shader_get_uniform(shd_pnctbw, "u_matpose");
shd_pnctbw_u_zoffset = shader_get_uniform(shd_pnctbw, "u_zoffset");
shd_pnctbw_u_normalsign = shader_get_uniform(shd_pnctbw, "u_normalsign");

room_goto_next();
