/// @desc Draw Models

draw_clear_alpha(0, 1);

var xx = CURRENT_FRAME/10;
draw_sprite_tiled_ext(spr_starbk, 0, xx, xx, 1, 1, 0x110703, 1);
draw_sprite_tiled_ext(spr_starbk, 1, xx, xx, 1, 1, 0x201010, 1);

var mats = [
	matrix_get(matrix_projection),
	matrix_get(matrix_view),
	matrix_get(matrix_world),
];

gpu_push_state();
gpu_set_cullmode(cull_clockwise);
gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);

matrix_set(matrix_projection, CAMERA3D.matproj);
matrix_set(matrix_view, CAMERA3D.matview);

// VBX
shader_set(shd_pnctbw);

var tex = sprite_get_texture(tex_pal_sue0, 0);

gpu_set_cullmode(fighter.forwardsign? cull_clockwise: cull_counterclockwise);
matrix_set(matrix_world, Mat4TranslateScaleXYZ(
	fighter.x/100, 0, fighter.y/100, fighter.forwardsign, 1, 1));
shader_set_uniform_matrix_array(HEADER.shd_pnctbw_u_matpose, fighter.matpose)
shader_set_uniform_f(HEADER.shd_pnctbw_u_zoffset, zoffset)

for (var i = 0; i < fighter.vbx.vbcount; i++)
{
	fighter.vbx.SubmitVBIndex(i, pr_trianglelist, tex);
}

shader_reset();
gpu_pop_state();

matrix_set(matrix_projection, mats[0])
matrix_set(matrix_view, mats[1])
matrix_set(matrix_world, mats[2])

