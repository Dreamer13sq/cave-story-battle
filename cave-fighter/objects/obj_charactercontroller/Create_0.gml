/// @desc

event_user(0);
event_user(1);

fighter = obj_fighter;

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
icommandframes = array_create(icommandcount, 0);
icommandsindex = 0;
icommanddirection = -1;	// Direction. -1 = Neutral
commandexecuted = "";

buffertimechain = 12;
buffertimetrigger = 12;

// [conditions, sequence, name]
sequencedefs = [
	["~36 ~32 ~36 A", "Zigzag Fwd A", "assist"],
	["~36 ~32 ~36 B", "Zigzag Fwd B", "assist"],
	["~36 ~32 ~36 C", "Zigzag Fwd C", "assist"],
	
	["2 2 A", "Double Dwn A", ""],
	["2 2 B", "Double Dwn B", ""],
	["2 2 C", "Double Dwn C", ""],
	
	// Start on down, Need to end on back
	["2 ~14 ~4 C", "Special Bck C", "air.001"],
	["2 ~14 ~4 B", "Special Bck B", "air.001"],
	["2 ~14 ~4 A", "Special Bck A", "air.001"],
	
	// Start on down, Need to end on forward
	["2 ~36 ~6 C", "Special Fwd C", "idle"],
	["2 ~36 ~6 B", "Special Fwd B", "idle"],
	["2 ~36 ~6 A", "Special Fwd A", "idle"],
	
	["A B C", "Triangle C", "assist"],
	["A B", "Triangle B", "assist"],
	
	["4AD", "Throw Back", "block"],
	["6AD", "Throw (Forward)", "block"],
	["AD", "Throw", "block"],
	
	["~2 ~8", "Super Jump", "air.001"],
	["~4D", "Backdash", "dash"],
	["~6D", "Dash", "dash"],
	["~6 5 ~6", "Dash (Input)", "dash"],
	["~4 5 ~4", "Backdash (Input)", "dash"],
	
	["~123C", "Crouch Heavy", "crouch-attack0a"],
	["~123B", "Crouch Medium", "crouch-attack0a"],
	["~123A", "Crouch Light", "crouch-attack0a"],
	
	["C", "Heavy", "attack0b"],
	["B", "Medium", "attack0b"],
	["A", "Light", "attack0a"],
	["D", "Parry", "block"],
];

var n = array_length(sequencedefs);
sequences = array_create(n);
for (var i = 0; i < n; i++)
{
	sequences[i] = ParseSequence(sequencedefs[i][0]);
	
	var ss = "";
	for (var j = 0; j < array_length(sequences[i]); j++)
	{
		ss += InputCmdChar(sequences[i][j]) + " ";
	}
	
	printf("%s: %s", sequencedefs[i][1], ss);
}

