/*
*/

function E_Fighter_Afterimage() : Entity() constructor
{
	vbx = -1;
	color = c_white;
	matpose = array_create(200*16);
	mattran = Mat4();
	texture = -1;
	
	forwardsign = 1;
	life = 20;
	
	tintpreset = 0;
	
	function Render3D()
	{
		if (BoolStep(life, 4))
		{
			matrix_set(matrix_world, mattran);
			gpu_set_cullmode(forwardsign? cull_clockwise: cull_counterclockwise);
			shader_set_uniform_matrix_array(HEADER.shd_pnctbw_u_matpose, matpose);
			U_Fighter_SetTint_Preset(tintpreset, 1.0);
			
			for (var i = 0; i < vbx.vbcount; i++)
			{
				vbx.SubmitVBIndex(i, pr_trianglelist, texture);
			}
		}
	}
	
	function Update(ts)
	{
		life -= ts;
		if (life <= 0)
		{
			Destroy(); 
			return;
		}
		
		mattran = Mat4TranslateScaleXYZ(x/100, z/100-0.01, y/100, forwardsign, 1, 1);
	}
}