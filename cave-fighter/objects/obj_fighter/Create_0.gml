/// @desc

event_user(0);	// Game Loop
event_user(1);	// Methods

enum FighterStateMode
{
	inmotion =	1<<0,
	standing =	1<<1,
	crouching =	1<<2,
	ground =	1<<3,
	air =		1<<4,
	blockstun =	1<<5,
	hitstun =	1<<6,
	sliding =	1<<7,
	air_rise =	1<<8,
	air_fall =	1<<9,
}

x = 0;
y = 0;

location = [0,0,0];
speedvec = [0,0,0];	// Set through events
postspeedvec = [0,0,0];	// Friction speed
zrot = 0;

state = 0;
fighterstate = 0;

walkforwardspeed = 3;
walkbackspeed = 2.7;
jumpheight = 10;
grav = -0.4;

// ===========================================================================

characterfolder = new CharFolder();
if (characterfolder.SearchFolder("D:/GitHub/Cave-Story-Fighter/cave-fighter/datafiles/curly/", 3) == -1)
{
	characterfolder.SearchFolder("C:/Users/Dreamer/Documents/GitHub/Cave-Story-Fighter/cave-fighter/datafiles/curly/", 3)
}


trkarray = [];
trkcount = characterfolder.GetTRKs(trkarray);
trkindex = irandom(trkcount-1);
trkactive = trkarray[trkindex];
animkey = "";
allowinterrupt = true;

palarray = [];
palcount = characterfolder.GetPALs(palarray);
palindex = irandom(palcount-1);
palactive = palarray[palindex];

vbm = characterfolder.files_vbm[? characterfolder.GetVBMName(0)];

localpose = Mat4Array(200);
matpose = Mat4ArrayFlat(200);
mattran = Mat4();
matshear = Mat4();

playbackframe = 0;

image_speed = 0;

function FighterModel()
{
	
}



