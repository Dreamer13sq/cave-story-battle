/// @desc

enum FL_ActionConditions
{
	onground = 1 << 0,
	inair = 1 << 1,
	
}

function FighterAction() constructor
{
	
}

function DefineFighterAction(state, conditions, cmdsequence)
{
		
}

function ActionHitbox() constructor
{
	active = false;
	rect = [0,0,0,0];
	
	damage = 0;
	blockstun = 0;
	
	properties_hit = [];
	properties_block = [];
	properties_counter = [];
	
}

