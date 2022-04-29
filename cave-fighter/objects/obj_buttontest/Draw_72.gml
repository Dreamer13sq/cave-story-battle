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

// Draw entities
var ll = ll_particle;
var nd = ll.headnode, ndnext;
while (nd)
{
	nd.Render3D();
	nd = nd.nodenext;
}

// Grid
matrix_set(matrix_world, Mat4());
vertex_submit(vb_grid, pr_linelist, -1);

matrix_set(matrix_world, Mat4());

matrix_set(matrix_view, CAMERA3D.matbillboard_yup);
vertex_submit(vb_axisbox, pr_trianglelist, -1);

// VBM ========================================================================
shader_set(shd_fighter);

gpu_set_cullmode(fighter.forwardsign? cull_clockwise: cull_counterclockwise);
matrix_set(matrix_world, Mat4Transform(
	fighter.x, 0, fighter.y,
	0, 0, 0,
	fighter.forwardsign, 1, 1)
);
shader_set_uniform_matrix_array(HEADER.shd_fighter_u_matpose, fighter.matpose);
shader_set_uniform_f(HEADER.shd_fighter_u_forwardsign, fighter.forwardsign);
shader_set_uniform_f(HEADER.shd_fighter_u_zoffset, 0);
U_Fighter_SetTint_Preset(0);

if fighter.FlagGet(FL_Fighter.dashing)
{
	if (fighter.powermeter != fighter.powermeterold)
	{
		if fighter.FrameElapsed(3)
		{
			if fighter.FrameStepBool(0, -1, 4)
			U_Fighter_SetTint_Preset((fighter.powermeter != fighter.powermeterold)? 
				FighterTintPreset.charge: FighterTintPreset.parry);
		}
		else
		{
			U_Fighter_SetTint_Preset(FighterTintPreset.white);
		}
	}
}

var c = CAMERA3D.GetLocationVec();
shearmat = U_Fighter_SetShear(c, [c[0],y,0], fighter.GetLocationVec(), -1.0*fighter.forwardsign, 1.0);

for (var i = 0; i < fighter.vbm.vbcount; i++)
{
	fighter.vbm.SubmitVBIndex(i, pr_trianglelist, fighter.activetexture);
}

// Draw entities
var ll = ll_battleentity;
var nd = ll.headnode, ndnext;
while (nd)
{
	ndnext = nd.nodenext;
	nd.Render3D();
	
	nd = ndnext;
}

shader_reset();
gpu_pop_state();

matrix_set(matrix_projection, mats[0]);
matrix_set(matrix_view, mats[1]);
matrix_set(matrix_world, mats[2]);

