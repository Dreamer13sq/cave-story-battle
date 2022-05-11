/// @desc

function SetAnimation(key, force_reset=false)
{
	if (ds_map_exists(characterfolder.files_trk, key+".trk"))
	{
		if (force_reset || key != animkey)
		{
			animkey = key;
			trkactive = characterfolder.files_trk[? animkey+".trk"];
			
			playbackframe = 0;
			allowinterrupt = false;
		
			ApplyFrameMatrices(trkactive, playbackframe, vbm.bonenames, matpose);
		}
		
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
	
	ClearStateFlag(FighterStateMode.inmotion);
	
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

function GetStateFlag(flags) {return (fighterstate & flags) == flags;}
function SetStateFlag(flags) {fighterstate |= flags;}
function ClearStateFlag(flags) {fighterstate &= ~flags;}
function ToggleStateFlag(flags) {fighterstate ^= flags;}

#endregion =============================================


