/// @desc

if (keyboard_check_pressed(KeyCode.M))
{
	shearbool = !shearbool;	
}

if (keyboard_check(KeyCode.R))
{
	ReloadFiles();	
}

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

if (trkactive)
{
	lev = LevKeyPressed(KeyCode.bracketRight, KeyCode.bracketLeft);
	if (lev != 0)
	{
		trkindex = Modulo(trkindex+lev, trkcount);
		trkactive = trkarray[trkindex];	
	}
}

