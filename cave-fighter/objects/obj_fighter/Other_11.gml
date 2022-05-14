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
	
	var b = buffer_load(_path+"action.txt");
	actiondata = [];
	ds_map_clear(labelmap);
	ParseActionEventText(actiondata, labelmap, buffer_read(b, buffer_text));
	buffer_delete(b);
	
	trkarray = [];
	trkcount = characterfolder.GetTRKs(trkarray);
	trkindex = irandom(trkcount-1);
	trkactive = trkarray[trkindex];
	
	palcount = characterfolder.GetPALs(palarray);
	palactive = palarray[palindex];
}

#region Actions ============================================

function ActionSet(key, force_restart=true)
{
	//key = string_lower(key);
	
	//printf("ActionSet(%s)", actionkey);
	
	if (force_restart || key != actionkey)
	{
		actionkey = key;
		printf("Action: " + actionkey);
		SetAnimation(key);
		
		frame = 1;
		
		//FighterRunner();
		ActionEventRunner(actionkey);
		UpdateFighterState(0);
	}
}

function ActionEventRunner(label)
{
	// Jump to label
	if (ds_map_exists(labelmap, label))
	{
		actionrunnerindex = labelmap[? label];
	}
	else
	{
		actionrunnerindex = 0;
		printf("label \"%s\" invalid", label)
	}
	
	ds_stack_clear(actionpositionstack);
	
	var args;
	
	actiondatasize = array_length(actiondata);
	
	while (actionrunnerindex != -1 && actionrunnerindex < actiondatasize)
	{
		args = actiondata[actionrunnerindex];
		actionrunnerindex++;
		
		switch(string_lower(args[0]))
		{
			case("goto"): Goto(AEL(args[1])); break;
			case("jump"): Jump(AEL(args[1])); break;
			case("return"): Return(); break;
			case("end"): End(); break;
			
			case("actionset"): ActionSet(AEL(args[1])); break;
			
			case("frameisjump"): FrameIsJump(AEL(args[1]), AEL(args[2])); break;
			case("frameisstartjump"): FrameIsStartJump(AEL(args[1])); break;
			case("frameisendjump"): FrameIsEndJump(AEL(args[1])); break;
			
			case("fighterflagset"): FighterFlagSet(AEL(args[1])); break;
			case("fighterflagclear"): FighterFlagClear(AEL(args[1])); break;
			
			case("setspeedx"): SetSpeedX(AEL(args[1])); break;
			case("setspeedy"): SetSpeedY(AEL(args[1])); break;
			case("approachspeedx"): ApproachSpeedY(AEL(args[1])); break;
			case("approachspeedy"): ApproachSpeedY(AEL(args[1])); break;
			
		}
	}
}

#endregion =================================================

#region Action Utility ===========================================

function FighterVar(key)
{
	return variable_struct_get(self, string_lower(key));
}

function InputPressed(input_index) {return controller == -1? false: controller.IPressed(input_index);}
function InputHeld(input_index) {return controller == -1? false: controller.IHeld(input_index);}
function InputReleased(input_index) {return controller == -1? false: controller.IReleased(input_index);}

#endregion =======================================================



