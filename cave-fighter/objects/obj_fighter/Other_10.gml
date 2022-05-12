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
	
	// Newframe
	if (lastframe == floor(frame))
	{
		frame += 1;
	}
	
	if (lastframe != floor(frame))
	{
		FighterRunner();
		
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
		
		SetAction("jumpland");
	}
	
	if (location[1] > 0)
	{
		speedvec[1] += grav;
		
		SetStateFlag(FL_FFlag.air);
		ClearStateFlag(FL_FFlag.crouching);
		ClearStateFlag(FL_FFlag.standing);
		ClearStateFlag(FL_FFlag.ground);
		
		if (speedvec[1] >= 1) 
		{
			SetStateFlag(FL_FFlag.air_rise);
			ClearStateFlag(FL_FFlag.air_fall);
		}
		else if (speedvec[1] <= 1)
		{
			SetStateFlag(FL_FFlag.air_fall);
			ClearStateFlag(FL_FFlag.air_rise);
		}
	}
	
	if ( !GetStateFlag(FL_FFlag.inmotion) )
	{
		if ( GetStateFlag(FL_FFlag.air) )
		{
			if ( GetStateFlag(FL_FFlag.air_rise) ) {SetAction("air-rise", false);}
			if ( GetStateFlag(FL_FFlag.air_fall) ) {SetAction("air", false);}
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

