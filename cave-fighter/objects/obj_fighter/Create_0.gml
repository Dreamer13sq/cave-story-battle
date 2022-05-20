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

fflagname = [];
fflagname[log2(FL_FFlag.inmotion)] = "inmotion";
fflagname[log2(FL_FFlag.allowinterrupt)] = "allowinterrupt";
fflagname[log2(FL_FFlag.standing)] = "standing";
fflagname[log2(FL_FFlag.crouching)] = "crouching";
fflagname[log2(FL_FFlag.ground)] = "ground";
fflagname[log2(FL_FFlag.air)] = "air";

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

controller = -1;

walkforwardspeed = 4;
walkbackspeed = 2.7;
dashforwardspeed = 7;
dashbackspeed = 6;
jumpheight = 10;
superjumpheight = 15;
jumpspeedforward = 3;
jumpspeedback = 3;
grav = -0.4;
deceleration = 0.7;

// Action ===========================================================================

actionkey = "";
actionmap = ds_map_create();
actionactive = 0;

actiondata = [];
labelmap = ds_map_create();
actionrunnerindex = -1;
actionpositionstack = ds_stack_create();

actionanimation = ds_map_create(); // {actionkey: [flatmatrixdata, framecount]}
actionframecount = 0;

hitboxcount = 16;
hitboxes = array_create(hitboxcount);
for (var i = 0; i < hitboxcount; i++) {hitboxes[i] = new ActionHitbox();}

// Animation ===========================================================================

trkarray = [];
trkcount = 0
trkindex = 0;
trkactive = noone;
animkey = "";

palarray = [];
palcount = 0;
palindex = irandom(255);
palactive = noone;

vb = -1;
vbm = -1;

localpose = Mat4Array(200);
matpose = Mat4ArrayFlat(200);
mattran = Mat4();
matshear = Mat4();
lasttranslate = [0,0,0];
translatekey = 0;

shearbool = false;

actionspeed = 1.0;

image_speed = 0;

function FighterModel()
{
	
}

characterfolder = new CharFolder();
ReloadFiles();

vbm = characterfolder.files_vbm[? characterfolder.GetVBMName(0)];
translatekey = 0;

