/// @desc Methods

function Update(ts)
{
	location[0] += speedvec[0];
	location[1] += speedvec[1];
	location[2] += speedvec[2];
	
	location[0] += postspeedvec[0];
	location[1] += postspeedvec[1];
	location[2] += postspeedvec[2];
	
	UpdateFighterState(ts);
	
	// Movement
	location[0] += LevKeyHeld(KeyCode.D, KeyCode.A);
	location[2] += LevKeyHeld(KeyCode.W, KeyCode.S);
	zrot += LevKeyHeld(KeyCode.Q, KeyCode.E);
	
	var lev;
	
	lev = LevKeyPressed(KeyCode.greaterThan, KeyCode.lessThan);
	if (lev != 0)
	{
		palindex = Modulo(palindex+lev, palcount);
	}
	
	mattran = Mat4Transform(
		location[0], location[2], location[1],
		0, 0, zrot,
		1, 1, 1
		);
	
	if (trkactive)
	{
		lev = LevKeyPressed(KeyCode.bracketRight, KeyCode.bracketLeft);
		if (lev != 0)
		{
			trkindex = Modulo(trkindex+lev, trkcount);
			trkactive = trkarray[trkindex];	
		}
	}
	
	// Progress playback
	if (playbackframe < trkactive.framecount-1)
	{
		playbackframe += 1;
		ApplyFrameMatrices(trkactive, playbackframe, vbm.bonenames, matpose);
	}
	// 
	else
	{
		OnAnimationEnd();	
	}
	
	allowinterrupt = (
		!GetStateFlag(FighterStateMode.inmotion) ||
		allowinterrupt || 
		playbackframe > trkactive.framecount/2
		);
}

function UpdateFighterState(ts)
{
	if (location[1] <= 0 && speedvec[1] < 0)
	{
		location[1] = 0;
		speedvec[1] = 0;
		
		SetStateFlag(FighterStateMode.ground);
		SetStateFlag(FighterStateMode.standing);
		ClearStateFlag(FighterStateMode.air);
	}
	
	if (location[1] > 0)
	{
		speedvec[1] += grav;
		
		SetStateFlag(FighterStateMode.air);
		ClearStateFlag(FighterStateMode.crouching);
		ClearStateFlag(FighterStateMode.standing);
		ClearStateFlag(FighterStateMode.ground);
		
		if (speedvec[1] >= 1) 
		{
			SetStateFlag(FighterStateMode.air_rise);
			ClearStateFlag(FighterStateMode.air_fall);
		}
		else if (speedvec[1] <= 1)
		{
			SetStateFlag(FighterStateMode.air_fall);
			ClearStateFlag(FighterStateMode.air_rise);
		}
	}
	
	if ( !GetStateFlag(FighterStateMode.inmotion) )
	{
		if ( GetStateFlag(FighterStateMode.air) )
		{
			if ( GetStateFlag(FighterStateMode.air_rise) ) {SetAnimation("air-rise");}
			if ( GetStateFlag(FighterStateMode.air_fall) ) {SetAnimation("air");}
		}
		else
		{
			if ( GetStateFlag(FighterStateMode.crouching) )
			{
				SetAnimation("crouch");	
			}
			else
			{
				SetAnimation("battle")	
			}
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

