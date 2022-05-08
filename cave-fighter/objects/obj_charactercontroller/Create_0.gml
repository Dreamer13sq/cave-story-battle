/// @desc

event_user(0);
event_user(1);

device = -1;

enum FighterStateMode
{
	standing = 1<<0,
	crouching = 1<<1,
	air = 1<<2,
	
	blockstun = 1<<3,
	hitstun = 1<<4,
	
}

padmap = [
	[gp_padr],
	[gp_padu],
	[gp_padl],
	[gp_padd],
	[gp_face3],
	[gp_face4],
	[gp_face2],
	[gp_face1],
	[gp_start],
	[gp_select],
];

ipressed = 0;
iheld = 0;
ireleased = 0;

icommandcount = 16;
icommands = array_create(icommandcount, 0);
icommandsindex = 0;
icommanddirection = -1;	// Direction. -1 = Neutral

sequences = [];


