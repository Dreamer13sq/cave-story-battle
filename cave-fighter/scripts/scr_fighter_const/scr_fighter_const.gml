/// @desc

#macro BTN_NEUTRAL 0
#macro BTN_FORWARD 1
#macro BTN_UP 2
#macro BTN_BACK 3
#macro BTN_DOWN 4
#macro BTN_A 5
#macro BTN_B 6
#macro BTN_C 7
#macro BTN_DASH 8

#macro COMMAND_INDEX_BITSPERINDEX 32
#macro SEQUENCEBUFFERFRAMES 6
#macro DASHBUFFERFRAMES 5
#macro LEAPBUFFERFRAMES 10

#macro HEALTHWIDTH 160
#macro DASHMETERFLASHTIME 20
#macro POWEREXCOST 40

enum ST_Fighter
{
	wait = 1,
	walkforward,
	walkback,
	crouch,
	crouchforward,
	crouchback,
	dash,
	dash_stop,
	run,
	run_stop,
	backdash,
	backdash_stop,
	
	block,
	blockcrouch,
	blockair,
	parry,
	redparry,
	
	jumpsquat,
	jump,
	jumpback,
	jumpforward,
	leapsquat,
	leap,
	leapback,
	leapforward,
	airdash,
	airbackdash,
	
	cancel_neutral,
	cancel_forward,
	cancel_back,
	cancel_up,
	cancel_air_neutral,
	cancel_air_forward,
	cancel_air_down,
	cancel_air_back,
	
	attack0,
	attack1,
	attack2,
	attack3,
	attack4,
	attack5,
	attack6,
	attack7,
	attack8,
	attack9,
	attack10,
	attack11,
	attack12,
	attack13,
	attack14,
	attack15,
	
	attackcrouch0,
	attackcrouch1,
	attackcrouch2,
	attackcrouch3,
	attackcrouch4,
	attackcrouch5,
	attackcrouch6,
	attackcrouch7,
	
	attackaerial0,
	attackaerial1,
	attackaerial2,
	attackaerial3,
	attackaerial4,
	attackaerial5,
	attackaerial6,
	attackaerial7,
	
	attackdash0,
	attackdash1,
	attackdash2,
	attackdash3,
	attackdash4,
	attackdash5,
	attackdash6,
	attackdash7,
	
	landing0,
	landing1,
	landing2,
	landing3,
	landing4,
	landing5,
	landing6,
	landing7,
	landing8,
	landing9,
	landing10,
	landing11,
	landing12,
	landing13,
	landing14,
	landing15,
	
	grab,
	grabcatch,
	grabbreak,
	forwardthrow,
	backthrow,
	
	skill0,	// Booster hop
	skill1, // Charge forward
	skill2,	// Charge up
	skill3,
	skill4,
	skill5,
	skill6,
	skill7,
	skill8,
	
	special0,	// Fireball lv1
	special1,	// Fireball lv1 up
	special2,	// Fireball lv3
	special3,	// Missile lv1
	special4,	// Missile lv2
	special5,	// Missile lv3
	special6,
	special7,
	special8,
	special9,
	special10,
	special11,
	special12,
	special13,
	special14,
	special15,
	
	super0,	// lv3 Blade
	super1,	// Spur beam
	super2,
	super3,
	super4,
	super5,
	super6,
	super7,
	
	intro0,
	intro1,
	intro2,
	intro3,
	win0,
	win1,
	win2,
	win3,
	lose0,
	lose1,
	lose2,
	lose3,
	draw0,
	draw1,
	draw2,
	draw3,
	taunt0,
	taunt1,
	taunt2,
	taunt3,
	
	// HURT STATES
	hurt0,	// light attack
	hurt1,	// medium attack
	hurt2,	// heavy attack
	hurt_air,
	hurt_twirl,
	hurt_spiral,
	hurt_fall0,
	hurt_fall1,
	hurt_bounce,
	hurt_slide,
	hurt_knockdown,
	hurt_stun,
	hurt_flipout,
	hurt_flyback,
	hurt_flyback_wallsplat,
	hurt_wallsplat,
	hurt_double,
	hurt_neck,
	hurt_pull,
	
	recover,
	recover_air,
	recover_grab, // Grab tech
	
	_end
}

enum FL_Fighter
{
	onground = 1<<0,
	airborne = 1<<1,
	dashing = 1<<2,
	
	caninterrupt = 1<<3,
	caninterruptjump = 1<<4,
	caninterruptdash = 1<<5,
	
	justlanding = 1<<6,
	justairborne = 1<<7,
	
	intangible = 1<<8,
	useddashbutton = 1<<9,
}

function BTNName(btn)
{
	switch(abs(btn))
	{
		default:	return "[???]";
		case(BTN_FORWARD):	return "[FORWARD]";
		case(BTN_UP):	return "[UP]";
		case(BTN_BACK):	return "[BACK]";
		case(BTN_DOWN):	return "[DOWN]";
		case(BTN_A):	return "(A)";
		case(BTN_B):	return "(B)";
		case(BTN_C):	return "(C)";
		case(BTN_DASH):	return "(DASH)";
	}
}

function BTNImage(btn)
{
	switch(btn)
	{
		default: return 12; break;
		case(BTN_FORWARD):	return 0; break;
		case(BTN_UP):	return 2; break;
		case(BTN_BACK):	return 4; break;
		case(BTN_DOWN):	return 6; break;
		case(BTN_A):	return 8; break;
		case(BTN_B):	return 9; break;
		case(BTN_C):	return 10; break;
		case(BTN_DASH):	return 11; break;
	}
}

function BTNColor(btn)
{
	switch(btn)
	{
		default: return c_white; break;
		case(BTN_FORWARD):
		case(BTN_UP):
		case(BTN_BACK):
		case(BTN_DOWN):	return c_white; break;
		case(BTN_A):	return c_lime; break;
		case(BTN_B):	return c_yellow; break;
		case(BTN_C):	return c_orange; break;
		case(BTN_DASH):	return c_aqua; break;
	}
}

function ST_Fighter_GetName(enumvalue)
{
	switch(enumvalue)
	{
		case(ST_Fighter.wait): return "wait";
		case(ST_Fighter.walkforward): return "walkforward";
		case(ST_Fighter.walkback): return "walkback";
		case(ST_Fighter.crouch): return "crouch";
		case(ST_Fighter.crouchforward): return "crouchforward";
		case(ST_Fighter.crouchback): return "crouchback";
		case(ST_Fighter.dash): return "dash";
		case(ST_Fighter.dash_stop): return "dash_stop";
		case(ST_Fighter.run): return "run";
		case(ST_Fighter.run_stop): return "run_stop";
		case(ST_Fighter.backdash): return "backdash";
		case(ST_Fighter.backdash_stop): return "backdash_stop";
		case(ST_Fighter.block): return "block";
		case(ST_Fighter.blockcrouch): return "blockcrouch";
		case(ST_Fighter.blockair): return "blockair";
		case(ST_Fighter.parry): return "parry";
		case(ST_Fighter.redparry): return "redparry";
		case(ST_Fighter.jumpsquat): return "jumpsquat";
		case(ST_Fighter.jump): return "jump";
		case(ST_Fighter.jumpback): return "jumpback";
		case(ST_Fighter.jumpforward): return "jumpforward";
		case(ST_Fighter.leapsquat): return "leapsquat";
		case(ST_Fighter.leap): return "leap";
		case(ST_Fighter.leapback): return "leapback";
		case(ST_Fighter.leapforward): return "leapforward";
		case(ST_Fighter.airdash): return "airdash";
		case(ST_Fighter.airbackdash): return "airbackdash";
		case(ST_Fighter.cancel_neutral): return "cancel_neutral";
		case(ST_Fighter.cancel_forward): return "cancel_forward";
		case(ST_Fighter.cancel_back): return "cancel_back";
		case(ST_Fighter.cancel_up): return "cancel_up";
		case(ST_Fighter.cancel_air_neutral): return "cancel_air_neutral";
		case(ST_Fighter.cancel_air_forward): return "cancel_air_forward";
		case(ST_Fighter.cancel_air_down): return "cancel_air_down";
		case(ST_Fighter.cancel_air_back): return "cancel_air_back";
		case(ST_Fighter.attack0): return "attack0";
		case(ST_Fighter.attack1): return "attack1";
		case(ST_Fighter.attack2): return "attack2";
		case(ST_Fighter.attack3): return "attack3";
		case(ST_Fighter.attack4): return "attack4";
		case(ST_Fighter.attack5): return "attack5";
		case(ST_Fighter.attack6): return "attack6";
		case(ST_Fighter.attack7): return "attack7";
		case(ST_Fighter.attack8): return "attack8";
		case(ST_Fighter.attack9): return "attack9";
		case(ST_Fighter.attack10): return "attack10";
		case(ST_Fighter.attack11): return "attack11";
		case(ST_Fighter.attack12): return "attack12";
		case(ST_Fighter.attack13): return "attack13";
		case(ST_Fighter.attack14): return "attack14";
		case(ST_Fighter.attack15): return "attack15";
		case(ST_Fighter.attackcrouch0): return "attackcrouch0";
		case(ST_Fighter.attackcrouch1): return "attackcrouch1";
		case(ST_Fighter.attackcrouch2): return "attackcrouch2";
		case(ST_Fighter.attackcrouch3): return "attackcrouch3";
		case(ST_Fighter.attackcrouch4): return "attackcrouch4";
		case(ST_Fighter.attackcrouch5): return "attackcrouch5";
		case(ST_Fighter.attackcrouch6): return "attackcrouch6";
		case(ST_Fighter.attackcrouch7): return "attackcrouch7";
		case(ST_Fighter.attackaerial0): return "attackaerial0";
		case(ST_Fighter.attackaerial1): return "attackaerial1";
		case(ST_Fighter.attackaerial2): return "attackaerial2";
		case(ST_Fighter.attackaerial3): return "attackaerial3";
		case(ST_Fighter.attackaerial4): return "attackaerial4";
		case(ST_Fighter.attackaerial5): return "attackaerial5";
		case(ST_Fighter.attackaerial6): return "attackaerial6";
		case(ST_Fighter.attackaerial7): return "attackaerial7";
		case(ST_Fighter.attackdash0): return "attackdash0";
		case(ST_Fighter.attackdash1): return "attackdash1";
		case(ST_Fighter.attackdash2): return "attackdash2";
		case(ST_Fighter.attackdash3): return "attackdash3";
		case(ST_Fighter.attackdash4): return "attackdash4";
		case(ST_Fighter.attackdash5): return "attackdash5";
		case(ST_Fighter.attackdash6): return "attackdash6";
		case(ST_Fighter.attackdash7): return "attackdash7";
		case(ST_Fighter.landing0): return "landing0";
		case(ST_Fighter.landing1): return "landing1";
		case(ST_Fighter.landing2): return "landing2";
		case(ST_Fighter.landing3): return "landing3";
		case(ST_Fighter.landing4): return "landing4";
		case(ST_Fighter.landing5): return "landing5";
		case(ST_Fighter.landing6): return "landing6";
		case(ST_Fighter.landing7): return "landing7";
		case(ST_Fighter.landing8): return "landing8";
		case(ST_Fighter.landing9): return "landing9";
		case(ST_Fighter.landing10): return "landing10";
		case(ST_Fighter.landing11): return "landing11";
		case(ST_Fighter.landing12): return "landing12";
		case(ST_Fighter.landing13): return "landing13";
		case(ST_Fighter.landing14): return "landing14";
		case(ST_Fighter.landing15): return "landing15";
		case(ST_Fighter.grab): return "grab";
		case(ST_Fighter.grabcatch): return "grabcatch";
		case(ST_Fighter.grabbreak): return "grabbreak";
		case(ST_Fighter.forwardthrow): return "forwardthrow";
		case(ST_Fighter.backthrow): return "backthrow";
		case(ST_Fighter.skill0): return "skill0";
		case(ST_Fighter.skill1): return "skill1";
		case(ST_Fighter.skill2): return "skill2";
		case(ST_Fighter.skill3): return "skill3";
		case(ST_Fighter.skill4): return "skill4";
		case(ST_Fighter.skill5): return "skill5";
		case(ST_Fighter.skill6): return "skill6";
		case(ST_Fighter.skill7): return "skill7";
		case(ST_Fighter.skill8): return "skill8";
		case(ST_Fighter.special0): return "special0";
		case(ST_Fighter.special1): return "special1";
		case(ST_Fighter.special2): return "special2";
		case(ST_Fighter.special3): return "special3";
		case(ST_Fighter.special4): return "special4";
		case(ST_Fighter.special5): return "special5";
		case(ST_Fighter.special6): return "special6";
		case(ST_Fighter.special7): return "special7";
		case(ST_Fighter.special8): return "special8";
		case(ST_Fighter.special9): return "special9";
		case(ST_Fighter.special10): return "special10";
		case(ST_Fighter.special11): return "special11";
		case(ST_Fighter.special12): return "special12";
		case(ST_Fighter.special13): return "special13";
		case(ST_Fighter.special14): return "special14";
		case(ST_Fighter.special15): return "special15";
		case(ST_Fighter.super0): return "super0";
		case(ST_Fighter.super1): return "super1";
		case(ST_Fighter.super2): return "super2";
		case(ST_Fighter.super3): return "super3";
		case(ST_Fighter.super4): return "super4";
		case(ST_Fighter.super5): return "super5";
		case(ST_Fighter.super6): return "super6";
		case(ST_Fighter.super7): return "super7";
		case(ST_Fighter.intro0): return "intro0";
		case(ST_Fighter.intro1): return "intro1";
		case(ST_Fighter.intro2): return "intro2";
		case(ST_Fighter.intro3): return "intro3";
		case(ST_Fighter.win0): return "win0";
		case(ST_Fighter.win1): return "win1";
		case(ST_Fighter.win2): return "win2";
		case(ST_Fighter.win3): return "win3";
		case(ST_Fighter.lose0): return "lose0";
		case(ST_Fighter.lose1): return "lose1";
		case(ST_Fighter.lose2): return "lose2";
		case(ST_Fighter.lose3): return "lose3";
		case(ST_Fighter.draw0): return "draw0";
		case(ST_Fighter.draw1): return "draw1";
		case(ST_Fighter.draw2): return "draw2";
		case(ST_Fighter.draw3): return "draw3";
		case(ST_Fighter.taunt0): return "taunt0";
		case(ST_Fighter.taunt1): return "taunt1";
		case(ST_Fighter.taunt2): return "taunt2";
		case(ST_Fighter.taunt3): return "taunt3";
		case(ST_Fighter.hurt0): return "hurt0";
		case(ST_Fighter.hurt1): return "hurt1";
		case(ST_Fighter.hurt2): return "hurt2";
		case(ST_Fighter.hurt_air): return "hurt_air";
		case(ST_Fighter.hurt_twirl): return "hurt_twirl";
		case(ST_Fighter.hurt_spiral): return "hurt_spiral";
		case(ST_Fighter.hurt_fall0): return "hurt_fall0";
		case(ST_Fighter.hurt_fall1): return "hurt_fall1";
		case(ST_Fighter.hurt_bounce): return "hurt_bounce";
		case(ST_Fighter.hurt_slide): return "hurt_slide";
		case(ST_Fighter.hurt_knockdown): return "hurt_knockdown";
		case(ST_Fighter.hurt_stun): return "hurt_stun";
		case(ST_Fighter.hurt_flipout): return "hurt_flipout";
		case(ST_Fighter.hurt_flyback): return "hurt_flyback";
		case(ST_Fighter.hurt_flyback_wallsplat): return "hurt_flyback_wallsplat";
		case(ST_Fighter.hurt_wallsplat): return "hurt_wallsplat";
		case(ST_Fighter.hurt_double): return "hurt_double";
		case(ST_Fighter.hurt_neck): return "hurt_neck";
		case(ST_Fighter.hurt_pull): return "hurt_pull";
		case(ST_Fighter.recover): return "recover";
		case(ST_Fighter.recover_air): return "recover_air";
		case(ST_Fighter.recover_grab): return "recover_grab";
		case(ST_Fighter._end): return "_end";
	}
	return "<unknown>";
}
