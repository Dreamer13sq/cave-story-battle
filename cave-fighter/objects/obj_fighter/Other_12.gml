/// @desc Fighter Runner

// Control -----------------------------------------------------------
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

// Frame -----------------------------------------------------------
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

// Flags -----------------------------------------------------------
function FighterFlagGet(flags) {return (fighterstate & flags) == flags;}
function FighterFlagSet(flags) {fighterstate |= flags;}
function FighterFlagClear(flags) {fighterstate &= ~flags;}
function FighterFlagToggle(flags) {fighterstate ^= flags;}

// Speed -----------------------------------------------------------
function SetSpeedX(spd, mult=1.0) {speedvec[0] = spd*mult;}
function SetSpeedY(spd, mult=1.0) {speedvec[1] = spd*mult;}
function AddSpeedX(spd, mult=1.0) {speedvec[0] += spd*mult;}
function AddSpeedY(spd, mult=1.0) {speedvec[1] += spd*mult;}
function ApproachSpeedX(spd, step, mult=1.0) {speedvec[0] = Approach(speedvec[0], spd*mult, step);}
function ApproachSpeedY(spd, step, mult=1.0) {speedvec[1] = Approach(speedvec[1], spd*mult, step);}

// Hitbox -----------------------------------------------------------
function HitboxReset()
{
	for (var i = 0; i < hitboxcount; i++) {HitboxDisable(i);}
}
function HitboxEnable(index) {hitboxes[index].active = true;}
function HitboxDisable(index) {hitboxes[index].active = false;}
function HitboxRect(index, x1, y1, x2, y2) 
{
	var rr = hitboxes[index].rect;
	rr[@ 0] = x1; rr[@ 1] = y1; rr[@ 2] = x2; rr[@ 3] = y2;
}



