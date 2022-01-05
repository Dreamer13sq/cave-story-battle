/// @desc Draw model

draw_clear_alpha(0, 1);

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

// Basic
matrix_set(matrix_world, Mat4());
vertex_submit(vb_grid, pr_linelist, -1);

// Model
shader_set(shd_pnct);

matrix_set(matrix_world, Mat4TranslateRotateScale(x, y, z, 0, 0, zrot, 1));

//vertex_submit(vb, pr_trianglelist, -1);

// VBX
shader_set(shd_pnctbw);

shader_set_uniform_matrix_array(HEADER.shd_pnctbw_u_matpose, matpose)
var tex = sprite_get_texture(tex_pal_sue0, 0);

for (var i = 0; i < vbx.vbcount; i++)
{
	vbx.SubmitVBIndex(i, pr_trianglelist, tex);
}

shader_reset();
gpu_pop_state();

matrix_set(matrix_projection, mats[0])
matrix_set(matrix_view, mats[1])
matrix_set(matrix_world, mats[2])


