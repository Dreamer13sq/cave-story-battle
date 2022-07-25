/// @desc Common

function Update(ts)
{
	// Update speeds
	location[0] += speedvec[0];
	location[1] += speedvec[1];
	location[2] += speedvec[2];
	
	location[0] += postspeedvec[0];
	location[1] += postspeedvec[1];
	location[2] += postspeedvec[2];
	
	if (location[1] > 0)
	{
		speedvec[1] += grav;
	}
	
	// Newframe
	UpdateFrame(ts);
	
	location[0] = Wrap(location[0], -200, 200);
	
	UpdateFighterState(ts);
	
	mattran = Mat4Transform(
		location[0], location[2], location[1],
		0, 0, zrot,
		1, 1, 1
		);
}

function UpdateFrame(ts)
{
	if (lastframe == floor(frame))
	{
		frame += ts * actionspeed;
	}
	
	if (lastframe != floor(frame))
	{
		FighterRunner();
		//ActionEventRunner(actionkey);
		
		if ( frame >= trkactive.FrameCount() )
		{
			OnAnimationEnd();
		}
		
		// Progress playback
		/*
		CalculateAnimationPose(
			vbm.bone_parentindices,
			vbm.bone_localmatricies,
			vbm.bone_inversematricies,
			actionanimation[? actionkey][frame-1],
			matpose
			);
		*/
		
		ApplyFrameMatrices(trkactive, frame-1, vbm.bonenames, matpose);
		
		lastframe = floor(frame);
		
		// Move by translation bone
		if (trkactive)
		{
			var newtranslation = Mat4GetTranslation(trkactive.GetFrameMatrices(frame-1));
			
			if (frame <= 1)
			{
				lasttranslate = newtranslation;
			}
		
			Mat4ArrayFlatSet(matpose, 0, Mat4());
		
			//printf(newtranslation[0] - lasttranslate[0])
		
			location[0] += newtranslation[0] - lasttranslate[0];
			location[2] += newtranslation[2] - lasttranslate[2];
			lasttranslate = newtranslation;
		}
		
	}
}

function UpdateFighterState(ts)
{
	// Just Landing
	if (location[1] <= 0 && speedvec[1] < 0)
	{
		location[1] = 0;
		speedvec[1] = 0;
		
		ActionSet("jumpland");
	}
	
	if (location[1] > 0)
	{
		FighterFlagSet(FL_FFlag.air);
		FighterFlagClear(FL_FFlag.crouching);
		FighterFlagClear(FL_FFlag.standing);
		FighterFlagClear(FL_FFlag.ground);
		
		if (speedvec[1] >= 1) 
		{
			FighterFlagSet(FL_FFlag.air_rise);
			FighterFlagClear(FL_FFlag.air_fall);
		}
		else if (speedvec[1] <= 1)
		{
			FighterFlagSet(FL_FFlag.air_fall);
			FighterFlagClear(FL_FFlag.air_rise);
		}
	}
	else
	{
		FighterFlagSet(FL_FFlag.ground);
		FighterFlagClear(FL_FFlag.air);
	}
	
	if ( !FighterFlagGet(FL_FFlag.inmotion) )
	{
		if ( FighterFlagGet(FL_FFlag.air) )
		{
			if ( FighterFlagGet(FL_FFlag.air_rise) ) {ActionSet("air-rise", false);}
			if ( FighterFlagGet(FL_FFlag.air_fall) ) {ActionSet("air", false);}
		}
		else
		{
			
		}
	}
}

function Render()
{
	matshear = Mat4GetPerspectiveCorrection(
		obj_battle.CameraPosition(),
		obj_battle.GameplayPosition(),
		Position()
	);
	
	if (!shearbool) {matshear = Mat4();}
	
	GRAPHICS.activeshader.UniformMatrix4("u_mattran", mattran);
	GRAPHICS.activeshader.UniformMatrix4("u_matpose", matpose);
	GRAPHICS.activeshader.UniformMatrix4("u_matshear", matshear);
	if (sprite_exists(palarray[palindex]))
	GRAPHICS.activeshader.UniformSampler2D("u_texture", sprite_get_texture(palarray[palindex], 0));
	
	//vertex_submit(vb, pr_trianglelist, -1);
	
	gpu_set_tex_filter(true);
	for (var i = 0; i < vbm.Count(); i++) {vbm.SubmitVBIndex(i);}
}

