/// @desc Attack Defs

event_inherited();

function FighterRunner()
{
	switch(actionkey)
	{
		default:
			printf("Action \"%s\" not found", actionkey);
			ActionSet("neutral");
			break;
		
		case("neutral"): // -------------------------------------------------
			if ( FrameIsStartJump() )
			{
				FighterFlagSet(FL_FFlag.standing | FL_FFlag.allowinterrupt);
				FighterFlagClear(FL_FFlag.inmotion | FL_FFlag.crouching | FL_FFlag.air);
			}
			
			ApproachSpeedX(0, FighterVar("deceleration"));
			break;
		
		case("crouch"): // -------------------------------------------------
			if ( FrameIsStartJump() )
			{
				FighterFlagSet(FL_FFlag.crouching | FL_FFlag.allowinterrupt);
				FighterFlagClear(FL_FFlag.inmotion | FL_FFlag.standing | FL_FFlag.air);
			}
			
			ApproachSpeedX(0, FighterVar("deceleration"));
			break;
		
		case("jumpsquat"): // -------------------------------------------------
			if ( FrameIsStartJump() ) {FighterFlagSet(FL_FFlag.inmotion);}
			if ( FrameIsEndJump() ) 
			{
				ActionSet("air-rise");
				SetSpeedY( FighterVar("jumpheight") );
			}
			break;
		
		case("jumpland"): // -------------------------------------------------
			if ( FrameIsStartJump() )
			{
				FighterFlagSet(FL_FFlag.standing | FL_FFlag.allowinterrupt | FL_FFlag.inmotion);
				FighterFlagClear(FL_FFlag.air);
			}
			ApproachSpeedX(0, FighterVar("deceleration"));
			if ( FrameIsEndJump() ) {ActionSet("neutral");}
			break;
		
		case("crouching"): // -------------------------------------------------
			if ( FrameIsStartJump() )
			{
				FighterFlagSet(FL_FFlag.crouching | FL_FFlag.allowinterrupt | FL_FFlag.inmotion);
				FighterFlagClear(FL_FFlag.standing | FL_FFlag.air);
			}
			ApproachSpeedX(0, FighterVar("deceleration"));
			if ( FrameIsEndJump() ) {ActionSet("crouch");}
			break;
		
		case("standing"): // -------------------------------------------------
			if ( FrameIsStartJump() )
			{
				FighterFlagSet(FL_FFlag.standing | FL_FFlag.allowinterrupt | FL_FFlag.inmotion);
				FighterFlagClear(FL_FFlag.crouching | FL_FFlag.air);
			}
			ApproachSpeedX(0, FighterVar("deceleration"));
			if ( FrameIsEndJump() ) {ActionSet("neutral");}
			break;
		
		case("air-rise"):
		case("air"): // -------------------------------------------------
			if ( FrameIsStartJump() )
			{
				FighterFlagSet(FL_FFlag.air | FL_FFlag.allowinterrupt);
				FighterFlagClear(FL_FFlag.inmotion | FL_FFlag.standing | FL_FFlag.crouching);
			}
			break;
		
		case("block"): // -------------------------------------------------
			if ( FrameIsStartJump() )
			{
				FighterFlagSet(FL_FFlag.standing | FL_FFlag.inmotion);
				FighterFlagClear(FL_FFlag.crouching | FL_FFlag.air);
			}
			
			if ( FrameIsEndJump() ) {ActionSet("neutral");}
			
			break;
		
		case("assist"): // -------------------------------------------------
			if ( FrameIsStartJump() ) 
			{
				FighterFlagSet(FL_FFlag.inmotion);
				FighterFlagClear(FL_FFlag.allowinterrupt);
			}
			if ( FrameIsEndJump() ) {ActionSet("neutral");}
			break;
		
		// ======================================================================
		
		case("walk"): // -------------------------------------------------
			ApproachSpeedX(walkforwardspeed, 1);
			break;
		
		case("walkback"): // -------------------------------------------------
			ApproachSpeedX(-walkbackspeed, 1);
			break;
		
		case("dash"): // -------------------------------------------------
			if ( FrameIsStartJump() ) 
			{
				FighterFlagSet(FL_FFlag.inmotion);
				SetSpeedX(dashforwardspeed);
				SetSpeedY(0);
			}
			
			ApproachSpeedX(dashforwardspeed, 1);
			
			if ( FrameIsJump(10) || FrameIsEndJump() ) 
			{
				ActionSet("neutral");
			}
			break;
		
		case("dashback"): // -------------------------------------------------
			if ( FrameIsStartJump() ) 
			{
				FighterFlagSet(FL_FFlag.inmotion);
				SetSpeedX(-dashbackspeed);
				SetSpeedY(0);
			}
			
			ApproachSpeedX(-dashbackspeed, 1);
			
			if ( FrameIsJump(10) || FrameIsEndJump() ) 
			{
				ActionSet("neutral");
			}
			break;
		
		// ======================================================================
		
		case("attack0a"):
		case("attack0b"):
		case("attack0c"): // -------------------------------------------------
			if ( FrameIsStartJump() )
			{
				FighterFlagSet(FL_FFlag.standing | FL_FFlag.inmotion);
				FighterFlagClear(FL_FFlag.crouching | FL_FFlag.air);
			}
			
			if ( FrameIsJump(3) ) {FighterFlagClear(FL_FFlag.allowinterrupt);}
			
			if ( FrameIsJump(17) ) {FighterFlagSet(FL_FFlag.allowinterrupt);}
			if ( FrameIsEndJump() ) {ActionSet("neutral");}
			
			ApproachSpeedX(0, FighterVar("deceleration"));
			break;
		
		case("crouch-attack0a"):
		case("crouch-attack0b"):
		case("crouch-attack0c"): // -------------------------------------------------
			if ( FrameIsStartJump() )
			{
				FighterFlagSet(FL_FFlag.crouching | FL_FFlag.inmotion);
				FighterFlagClear(FL_FFlag.standing | FL_FFlag.air);
			}
			
			if ( FrameIsJump(3) ) {FighterFlagClear(FL_FFlag.allowinterrupt);}
			
			if ( FrameIsJump(13) ) {FighterFlagSet(FL_FFlag.allowinterrupt);}
			if ( FrameIsEndJump() ) {ActionSet("crouch");}
			
			ApproachSpeedX(0, FighterVar("deceleration"));
			break;
	}
}


