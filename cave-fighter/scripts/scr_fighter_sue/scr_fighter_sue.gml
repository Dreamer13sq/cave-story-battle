/// @desc

function Fighter_Sue() : Fighter() constructor
{
	vbx = OpenVBX("sue/model.vbx", HEADER.vbf_pnctbw);
	LoadFighterPoses("sue/pose/", poseset);
	SetPose(variable_struct_get_names(poseset)[0]);
	
	Runner = Fighter_Sue_Runner;
}

function Fighter_Sue_Runner()
{
	switch(state)
	{
		// ----------------------------------------------------------
		default:{
			DefaultRunner();
		}
		break;
		
		// ----------------------------------------------------------
		case(ST_Fighter.wait):{
			SetPose("idle0");
			DefaultRunner();
		}
		break;
		
		// ----------------------------------------------------------
		case(ST_Fighter.walkforward):{
			SetPose("walk");
			DefaultRunner();
		}
		break;
		
		// ----------------------------------------------------------
		case(ST_Fighter.walkback):{
			SetPose("walk");
			DefaultRunner();
		}
		break;
		
		// ----------------------------------------------------------
		case(ST_Fighter.airdash):
		case(ST_Fighter.dash):{
			SetPose("dashstart");
			DefaultRunner();
		}
		break;
		
		// ----------------------------------------------------------
		case(ST_Fighter.airbackdash):
		case(ST_Fighter.backdash):{
			SetPose("dashback");
			DefaultRunner();
		}
		break;
		
		// ----------------------------------------------------------
		case(ST_Fighter.leapforward):
		case(ST_Fighter.leapback):
		case(ST_Fighter.leap):
			
			
		case(ST_Fighter.jumpforward):
		case(ST_Fighter.jumpback):
		case(ST_Fighter.jump):{
			if yspeed > 0 {SetPose("jumprise")}
			else {SetPose("jumpfall");}
			DefaultRunner();
		}
		break;
		
	}
}