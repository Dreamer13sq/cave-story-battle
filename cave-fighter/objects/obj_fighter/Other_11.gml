/// @desc

function SetAnimation(key)
{
	if (ds_map_exists(characterfolder.files_trk, key+".trk"))
	{
		animkey = key;
		trkactive = characterfolder.files_trk[? animkey+".trk"];
		playbackframe = 0;
		allowinterrupt = false;
		
		ApplyFrameMatrices(trkactive, playbackframe, vbm.bonenames, matpose);
	}
}

function OnAnimationEnd()
{
	if (animkey != "battle" && animkey != "crouch" && animkey != "air" && animkey != "assist")
	{
		if (string_pos("crouch", animkey)) {SetAnimation("crouch");}
		else if (string_pos("air", animkey)) {SetAnimation("air");}
		else {SetAnimation("battle");}
	}
	
	allowinterrupt = true;
	
	playbackframe = 0;
}

#region Utility =============================================

function Position() {return location;}

function SetPositionXY(xx, yy)
{
	x = xx;
	y = yy;
}

function AddPosition(xx, yy)
{
	x += xx;
	y += yy;
}

#endregion =============================================


