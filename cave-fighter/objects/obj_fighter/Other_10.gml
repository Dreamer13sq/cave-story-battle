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
	if (lastframe == floor(frame))
	{
		frame += 1;
	}
	
	if (lastframe != floor(frame))
	{
		FighterRunner();
		//ActionEventRunner(actionkey);
		
		// Progress playback
		if (frame-1 < trkactive.framecount-1)
		{
			ApplyFrameMatrices(trkactive, frame-1, vbm.bonenames, matpose);
		}
		// 
		else
		{
			OnAnimationEnd();
		}
		
		lastframe = floor(frame);
	}
	
	UpdateFighterState(ts);
	
	mattran = Mat4Transform(
		location[0], location[2], location[1],
		0, 0, zrot,
		1, 1, 1
		);
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
	GRAPHICS.activeshader.UniformSampler2D("u_texture", sprite_get_texture(palarray[palindex], 0));
	
	for (var i = 0; i < vbm.vbcount; i++) {vbm.SubmitVBIndex(i);}
}

