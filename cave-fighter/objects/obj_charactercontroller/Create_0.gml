/// @desc

event_user(0);
event_user(1);

fighter = obj_fighter;

device = -1;

keymap = [
	[vk_right], [vk_up], [vk_left], [vk_down],
	[ord("Z")], [ord("X")], [ord("C")], [vk_space],
	[vk_enter], [vk_shift],
];

padmap = [
	[gp_padr], [gp_padu], [gp_padl], [gp_padd],
	[gp_face3], [gp_face4], [gp_face2], [gp_face1],
	[gp_start], [gp_select],
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
buffertimetrigger = 7;

// [conditions, sequence, name]
sequencedefs = [
	["2 ~14 ~4 ~*BC", "Super Bck", "block", FighterStateMode.ground],
	["2 ~36 ~6 ~*BC", "Super Fwd", "block", FighterStateMode.ground],
	["2 ~14 ~4 ~5 ~*BC", "Super Bck (Space)", "block", FighterStateMode.ground],
	["2 ~36 ~6 ~5 ~*BC", "Super Fwd (Space)", "block", FighterStateMode.ground],
	
	["~36 ~32 ~36 A", "Zigzag Fwd A", "assist", FighterStateMode.ground],
	["~36 ~32 ~36 B", "Zigzag Fwd B", "assist", FighterStateMode.ground],
	["~36 ~32 ~36 C", "Zigzag Fwd C", "assist", FighterStateMode.ground],
	
	["2 2 A", "Double Dwn A", "", FighterStateMode.ground],
	["2 2 B", "Double Dwn B", "", FighterStateMode.ground],
	["2 2 C", "Double Dwn C", "", FighterStateMode.ground],
	
	// Start on down, Need to end on back
	["2 ~14 ~4 C", "Special Bck C", "air-rise", FighterStateMode.ground],
	["2 ~14 ~4 B", "Special Bck B", "air-rise", FighterStateMode.ground],
	["2 ~14 ~4 A", "Special Bck A", "air-rise", FighterStateMode.ground],
	
	// Start on down, Need to end on forward
	["2 ~36 ~6 C", "Special Fwd C", "idle", FighterStateMode.ground],
	["2 ~36 ~6 B", "Special Fwd B", "idle", FighterStateMode.ground],
	["2 ~36 ~6 A", "Special Fwd A", "idle", FighterStateMode.ground],
	
	["A B C", "Triangle C", "assist", FighterStateMode.ground],
	["A B", "Triangle B", "assist", FighterStateMode.ground],
	
	["BC", "Skill", "assist", 0],
	
	["4AD", "Throw Back", "block", FighterStateMode.ground],
	["6AD", "Throw (Forward)", "block", FighterStateMode.ground],
	["AD", "Throw", "block", FighterStateMode.ground],
	
	["~2 ~8", "Super Jump", "air-rise", FighterStateMode.ground],
	["~2 ~456 ~8", "Super Jump (3)", "air-rise", FighterStateMode.ground],
	//["~2 ~456 ~8", "Super Jump (4)", "air-rise"],
	["~4D", "Backdash", "dash", 0],
	["~6D", "Dash", "dash", 0],
	["~6 ~6", "Dash (Input)", "dash", 0],
	["~4 ~4", "Backdash (Input)", "dash", 0],
	
	["~123C", "Crouch Heavy", "crouch-attack0a", FighterStateMode.crouching],
	["~123B", "Crouch Medium", "crouch-attack0a", FighterStateMode.crouching],
	["~123A", "Crouch Light", "crouch-attack0a", FighterStateMode.crouching],
	
	["C", "Heavy", "attack0b", FighterStateMode.standing],
	["B", "Medium", "attack0b", FighterStateMode.standing],
	["A", "Light", "attack0a", FighterStateMode.standing],
	["D", "Parry", "block", FighterStateMode.standing],
];

var n = array_length(sequencedefs);
sequences = array_create(n);
for (var i = 0; i < n; i++)
{
	sequences[i][0] = ParseSequence(sequencedefs[i][0]);
	sequences[i][1] = sequencedefs[i][3];
	
	var ss = "";
	for (var j = 0; j < array_length(sequences[i][0]); j++)
	{
		ss += InputCmdChar(sequences[i][0][j]) + " ";
	}
	
	printf("%s: %s", sequencedefs[i][1], ss);
}

