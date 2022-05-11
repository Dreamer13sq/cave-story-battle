/// @desc Methods

function SetAnimation(key, force_reset=false)
{
	if (ds_map_exists(characterfolder.files_trk, key+".trk"))
	{
		if (force_reset || key != animkey)
		{
			animkey = key;
			trkactive = characterfolder.files_trk[? animkey+".trk"];
			
			frame = 1;
			lastframe = 0;
			ApplyFrameMatrices(trkactive, frame-1, vbm.bonenames, matpose);
		}
		
	}
}

function OnAnimationEnd()
{
	frame = 1;
	return;
	
	
	if (animkey != "neutral" && animkey != "crouch" && animkey != "air" && animkey != "assist")
	{
		if (string_pos("crouch", animkey)) {SetAction("crouch");}
		else if (string_pos("air", animkey)) {SetAction("air");}
		else {SetAction("neutral");}
	}
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

function ReloadFiles()
{
	if (characterfolder.SearchFolder("D:/GitHub/Cave-Story-Fighter/cave-fighter/datafiles/curly/", 3) == -1)
	{
		characterfolder.SearchFolder("C:/Users/Dreamer/Documents/GitHub/Cave-Story-Fighter/cave-fighter/datafiles/curly/", 3)
	}
	
	trkarray = [];
	trkcount = characterfolder.GetTRKs(trkarray);
	trkindex = irandom(trkcount-1);
	trkactive = trkarray[trkindex];
}

#region Actions ============================================

function SetAction(key, force_restart=true)
{
	key = string_lower(key);
	
	//printf("SetAction(%s)", actionkey);
	
	//if (key != actionkey)
	if (force_restart || key != actionkey)
	{
		actionkey = key;
		printf("Action: " + actionkey);
		SetAnimation(key);
		
		frame = 1;
		
		FighterRunner();
	}
}

function ActionEventRunner()
{
	// [frame, command_index, arg0, arg1, ...]
	
	if (!actionactive) {return;}
	
	var ev;
	var n = array_length(actionactive);
	
	for (var i = 0; i < n; i++)
	{
		ev = actionactive[i];
		if (ev[0] != frame) {continue;}
		
		switch(ev[1])
		{
			// Jump to action
			case(ActionEventCommand.action):
				SetAction(ev[2]);
				break;
			
			// Set Flag
			case(ActionEventCommand.fighterflag_enable): SetStateFlag(ev[2]); break;
			case(ActionEventCommand.fighterflag_disable): ClearStateFlag(ev[2]); break;
		}
	}
}

#endregion =================================================

#region Action Utility ===========================================

function FrameIs(_frame) {return floor(frame) == _frame;}
function FrameIsEnd() {return floor(frame) == trkactive.framecount;}
function FrameIsStart() {return floor(frame) == 1;}

#endregion =======================================================



