/// @desc Methods

function Update(ts)
{
	location[0] += LevKeyHeld(KeyCode.D, KeyCode.A);
	location[2] += LevKeyHeld(KeyCode.W, KeyCode.S);
	zrot += LevKeyHeld(KeyCode.Q, KeyCode.E);
	
	var lev;
	
	lev = LevKeyPressed(KeyCode.greaterThan, KeyCode.lessThan);
	if (lev != 0)
	{
		palindex = Modulo(palindex+lev, palcount);
		palactive = palarray[palindex];
	}
	
	mattran = Mat4Transform(
		location[0], location[1], location[2],
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
	
	playbackframe = Modulo(playbackframe+1, trkactive.framecount);
	ApplyFrameMatrices(trkactive, playbackframe, vbm.bonenames, matpose);
}

function Render()
{
	matshear = Mat4GetPerspectiveCorrection(
		obj_battle.CameraPosition(),
		obj_battle.GameplayPosition(),
		Position()
	);
	
	GRAPHICS.activeshader.UniformMatrix4("u_mattran", mattran);
	GRAPHICS.activeshader.UniformMatrix4("u_matpose", matpose);
	GRAPHICS.activeshader.UniformMatrix4("u_matshear", matshear);
	GRAPHICS.activeshader.UniformSampler2D("u_texture", sprite_get_texture(palactive, 0));
	
	for (var i = 0; i < vbm.vbcount; i++)
	{
		vbm.SubmitVBIndex(i);
	}
}

