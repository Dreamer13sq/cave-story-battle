/// @desc

event_user(0);
event_user(1);

fighter = obj_fighter;
fighter.controller = self;

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

bufferedaction = "";	// Action to start when interrupt is allowed
bufferedactiontime = 5;	// Max number of frames the action can be inputted ahead of time
bufferedactionstep = 0;	// Decrementing value
bufferedactionindex = 0xFF;	// Where to stop parsing sequences. 
//Lower priority actions will not be processed until buffer runs out or action is executed

// [conditions, sequence, name]
sequencedefs = [
	["2 ~14 ~4 ~*BC", "Super Bck", "block", FL_FFlag.ground],
	["2 ~36 ~6 ~*BC", "Super Fwd", "block", FL_FFlag.ground],
	["2 ~14 ~4 ~5 ~*BC", "Super Bck (Space)", "block", FL_FFlag.ground],
	["2 ~36 ~6 ~5 ~*BC", "Super Fwd (Space)", "block", FL_FFlag.ground],
	
	["~36 ~32 ~36 A", "Zigzag Fwd A", "assist", FL_FFlag.ground],
	["~36 ~32 ~36 B", "Zigzag Fwd B", "assist", FL_FFlag.ground],
	["~36 ~32 ~36 C", "Zigzag Fwd C", "assist", FL_FFlag.ground],
	
	["2 2 A", "Double Dwn A", "", FL_FFlag.ground],
	["2 2 B", "Double Dwn B", "", FL_FFlag.ground],
	["2 2 C", "Double Dwn C", "", FL_FFlag.ground],
	
	// Start on down, Need to end on back
	["2 ~14 ~4 C", "Special Bck C", "air-rise", FL_FFlag.ground],
	["2 ~14 ~4 B", "Special Bck B", "air-rise", FL_FFlag.ground],
	["2 ~14 ~4 A", "Special Bck A", "air-rise", FL_FFlag.ground],
	
	// Start on down, Need to end on forward
	["2 ~36 ~6 C", "Special Fwd C", "idle", FL_FFlag.ground],
	["2 ~36 ~6 B", "Special Fwd B", "idle", FL_FFlag.ground],
	["2 ~36 ~6 A", "Special Fwd A", "idle", FL_FFlag.ground],
	
	["A B C", "Triangle C", "assist", FL_FFlag.ground],
	["A B", "Triangle B", "assist", FL_FFlag.ground],
	
	["BC", "Skill", "assist", 0],
	
	["4AD", "Throw Back", "block", FL_FFlag.ground],
	["6AD", "Throw (Forward)", "block", FL_FFlag.ground],
	["AD", "Throw", "block", FL_FFlag.ground],
	
	["~2 ~8", "Super Jump", "air-rise", FL_FFlag.ground],
	["~2 ~456 ~8", "Super Jump (3)", "air-rise", FL_FFlag.ground],
	//["~2 ~456 ~8", "Super Jump (4)", "air-rise"],
	["~4D", "Backdash", "dashback", 0],
	["~6D", "Dash", "dash", 0],
	["~6 ~6", "Dash (Input)", "dash", 0],
	["~4 ~4", "Backdash (Input)", "dashback", 0],
	
	["~123C", "Crouch Heavy", "crouch-attack0c", FL_FFlag.crouching],
	["~123B", "Crouch Medium", "crouch-attack0b", FL_FFlag.crouching],
	["~123A", "Crouch Light", "crouch-attack0a", FL_FFlag.crouching],
	
	["C", "Heavy", "attack0b", FL_FFlag.standing],
	["B", "Medium", "attack0b", FL_FFlag.standing],
	["A", "Light", "attack0a", FL_FFlag.standing],
	["D", "Parry", "block", FL_FFlag.standing],
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
	
	//printf("%s: %s", sequencedefs[i][1], ss);
}

