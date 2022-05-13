/// @desc

event_user(0);	// Game Loop
event_user(1);	// Methods
event_user(2);	// Fighter Runner

enum FL_FFlag
{
	inmotion =	1<<0,
	allowinterrupt =	1<<1,
	standing =	1<<2,
	crouching =	1<<3,
	ground =	1<<4,
	air =		1<<5,
	blockstun =	1<<6,
	hitstun =	1<<7,
	sliding =	1<<8,
	air_rise =	1<<9,
	air_fall =	1<<10,
}

x = 0;
y = 0;

location = [0,0,0];
speedvec = [0,0,0];	// Set through events
postspeedvec = [0,0,0];	// Friction speed
zrot = 0;

state = 0;
fighterstate = 0;
frame = 1;
lastframe = 0;
sidesign = 1;

walkforwardspeed = 4;
walkbackspeed = 2.7;
dashforwardspeed = 7;
dashbackspeed = 6;
jumpheight = 10;
jumpspeedforward = 3;
jumpspeedback = 3;
grav = -0.4;
deceleration = 0.7;

// ===========================================================================

characterfolder = new CharFolder();
ReloadFiles();

trkarray = [];
trkcount = characterfolder.GetTRKs(trkarray);
trkindex = irandom(trkcount-1);
trkactive = trkarray[trkindex];
animkey = "";

palarray = [];
palcount = characterfolder.GetPALs(palarray);
palindex = irandom(palcount-1);
palactive = palarray[palindex];

vbm = characterfolder.files_vbm[? characterfolder.GetVBMName(0)];

localpose = Mat4Array(200);
matpose = Mat4ArrayFlat(200);
mattran = Mat4();
matshear = Mat4();

shearbool = false;

image_speed = 0;

controller = -1;

// Action ===========================================================================

actionkey = "";
actionmap = ds_map_create();
actionactive = 0;

function FighterModel()
{
	
}



