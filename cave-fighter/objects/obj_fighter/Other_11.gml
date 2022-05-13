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
	var _path = "fighter/curly/";
	if (characterfolder.SearchFolder("D:/GitHub/Cave-Story-Fighter/cave-fighter/datafiles/"+_path, 3) == -1)
	{
		if (characterfolder.SearchFolder("C:/Users/Dreamer/Documents/GitHub/Cave-Story-Fighter/cave-fighter/datafiles/"+_path, 3) == -1)
		{
			characterfolder.SearchFolder(_path, 3);
		}
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
		UpdateFighterState(0);
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

function SetSpeedX(spd) {speedvec[0] = spd;}
function SetSpeedY(spd) {speedvec[1] = spd;}
function AddSpeedX(spd) {speedvec[0] += spd;}
function AddSpeedY(spd) {speedvec[1] += spd;}
function ApproachSpeedX(spd, step) {speedvec[0] = Approach(speedvec[0], spd, step);}
function ApproachSpeedY(spd, step) {speedvec[1] = Approach(speedvec[1], spd, step);}

function FighterVar(key)
{
	return variable_struct_get(self, string_lower(key));
}

function InputPressed(input_index) {return controller == -1? false: controller.IPressed(input_index);}
function InputHeld(input_index) {return controller == -1? false: controller.IHeld(input_index);}
function InputReleased(input_index) {return controller == -1? false: controller.IReleased(input_index);}

#endregion =======================================================



