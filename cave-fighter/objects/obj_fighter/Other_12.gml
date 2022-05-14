/// @desc Fighter Runner

function FighterFlagGet(flags) {return (fighterstate & flags) == flags;}
function FighterFlagSet(flags) {fighterstate |= flags;}
function FighterFlagClear(flags) {fighterstate &= ~flags;}
function FighterFlagToggle(flags) {fighterstate ^= flags;}

function FrameIsJump(_frame, label="") 
{
	if (floor(frame) == _frame)
	{
		ds_stack_push(actionpositionstack, actionrunnerindex);
		if (label != "")
		actionrunnerindex = labelmap[? label];
		return true;
	}
	return false;
}

function FrameIsEndJump(label="") 
{
	if (floor(frame) == trkactive.framecount)
	{
		ds_stack_push(actionpositionstack, actionrunnerindex);
		if (label != "")
		actionrunnerindex = labelmap[? label];
		return true;
	};
	return false;
}

function FrameIsStartJump(label="")
{
	if (floor(frame) == 1)
	{
		ds_stack_push(actionpositionstack, actionrunnerindex);
		if (label != "")
		actionrunnerindex = labelmap[? label];
		return true;
	};
	return false;
}

function SetSpeedX(spd) {speedvec[0] = spd;}
function SetSpeedY(spd) {speedvec[1] = spd;}
function AddSpeedX(spd) {speedvec[0] += spd;}
function AddSpeedY(spd) {speedvec[1] += spd;}
function ApproachSpeedX(spd, step) {speedvec[0] = Approach(speedvec[0], spd, step);}
function ApproachSpeedY(spd, step) {speedvec[1] = Approach(speedvec[1], spd, step);}

function End()
{
	actionrunnerindex = -1;
}

function Return()
{
	actionrunnerindex = ds_stack_pop(actionpositionstack);
}

function Jump(label)
{
	ds_stack_push(actionpositionstack, actionrunnerindex);
	actionrunnerindex = labelmap[? label];
}

function Goto(label)
{
	actionrunnerindex = labelmap[? label];
}

