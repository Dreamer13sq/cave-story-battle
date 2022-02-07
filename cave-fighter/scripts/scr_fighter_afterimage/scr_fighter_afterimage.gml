/*
*/

function E_Fighter_Afterimage() : Entity() constructor
{
	vbm = -1;
	color = c_white;
	matpose = array_create(200*16);
	mattran = Mat4();
	texture = -1;
	
	forwardsign = 1;
	lifemax = 20;
	life = lifemax;
	
	tintpreset = 0;
	
	function Render3D()
	{
		if (BoolStep(life, 3))
		{
			matrix_set(matrix_world, mattran);
			gpu_set_cullmode(forwardsign? cull_clockwise: cull_counterclockwise);
			shader_set_uniform_matrix_array(HEADER.shd_fighter_u_matpose, matpose);
			shader_set_uniform_f(HEADER.shd_fighter_u_forwardsign, forwardsign);
			shader_set_uniform_f(HEADER.shd_fighter_u_zoffset, 1+life/lifemax);
			U_Fighter_SetTint_Preset(tintpreset, 1.0);
			
			for (var i = 0; i < vbm.vbcount; i++)
			{
				vbm.SubmitVBIndex(i, pr_trianglelist, texture);
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
		
		mattran = Mat4Transform(x, 0, y, 0, 0, 0, forwardsign, 1, 1);
	}
}

function CreateHitBall(fighter)
{
	var nd = NewEntity_Particle(new E_Hitball());
	var n = nd.elementcount;
	var center = [fighter.x, 0, fighter.y+50];
	var loc, dir;
	
	for (var i = 0; i < n; i++)
	{
		loc = [
			center[0] + random_range(1, 30) * RandomSign(),
			center[1] + random_range(1, 30) * RandomSign(),
			center[2] + random_range(1, 30) * RandomSign()
		];
		
		dir = Vec3NormalizedXYZ(
			loc[0]-center[0],
			loc[1]-center[1],
			loc[2]-center[2]
			);
		
		nd.element[i] = [
			loc[0], loc[1], loc[2],
			dir[0], dir[1], dir[2],
			10
			];
	}
}
