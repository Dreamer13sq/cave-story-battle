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
				FighterFlagClear(FL_FFlag.inmotion | FL_FFlag.crouching | FL_FFlag.air | FL_FFlag.dashing);
				HitboxReset();
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
				SetSpeedY( FighterVar("jumpheight") );
				ActionSet("air-rise");
			}
			break;
		
		case("superjumpsquat"): // -------------------------------------------------
			if ( FrameIsStartJump() ) {FighterFlagSet(FL_FFlag.inmotion);}
			if ( FrameIsEndJump() ) 
			{
				SetSpeedY( FighterVar("superjumpheight") );
				ActionSet("air-rise");
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
		
		case("idle"): // -------------------------------------------------
			if ( FrameIsStartJump() ) 
			{
				FighterFlagSet(FL_FFlag.inmotion);
				FighterFlagClear(FL_FFlag.allowinterrupt);
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
			if ( FrameIsStartJump() )
			{
				FighterFlagClear(FL_FFlag.inmotion);
			}
			//ApproachSpeedX(walkforwardspeed, 1);
			break;
		
		case("walkforward"): // -------------------------------------------------
			if ( FrameIsStartJump() )
			{
				FighterFlagClear(FL_FFlag.inmotion);
			}
			//ApproachSpeedX(0, FighterVar("deceleration"));
			ApproachSpeedX(walkforwardspeed, 1);
			break;
		
		case("walkback"): // -------------------------------------------------
			if ( FrameIsStartJump() )
			{
				FighterFlagClear(FL_FFlag.inmotion);
			}
			ApproachSpeedX(-walkbackspeed, 1);
			break;
		
		case("dash"): // -------------------------------------------------
			if ( FrameIsStartJump() ) 
			{
				FighterFlagSet(FL_FFlag.inmotion | FL_FFlag.dashing);
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
		
		case("attack0a"): // -------------------------------------------------
			if ( FrameIsStartJump() )
			{
				FighterFlagSet(FL_FFlag.standing | FL_FFlag.inmotion);
				FighterFlagClear(FL_FFlag.crouching | FL_FFlag.air);
			}
			
			if ( FrameIsJump(3) ) {FighterFlagClear(FL_FFlag.allowinterrupt);}
			
			if ( FrameIsJump(5) ) // Hitbox
			{
				HitboxEnable(0);
				HitboxRect(0, 16, 64, 68, 124);
			}
			
			if ( FrameIsJump(9) ) {HitboxReset();}
			
			if ( FrameIsJump(17) ) {FighterFlagSet(FL_FFlag.allowinterrupt);}
			if ( FrameIsEndJump() ) {ActionSet("neutral");}
			
			ApproachSpeedX(0, FighterVar("deceleration"));
			break;
		
		case("attack0b"): // -------------------------------------------------
			if ( FrameIsStartJump() )
			{
				FighterFlagSet(FL_FFlag.standing | FL_FFlag.inmotion);
				FighterFlagClear(FL_FFlag.crouching | FL_FFlag.air);
			}
			
			if ( FrameIsJump(3) ) {FighterFlagClear(FL_FFlag.allowinterrupt);}
			
			if ( FrameIsJump(8) ) // Hitbox
			{
				HitboxEnable(0);
				HitboxRect(0, 32, 52, 92, 112);
			}
			if ( FrameIsJump(11) ) {HitboxReset();}
			
			if ( FrameIsJump(17) ) {FighterFlagSet(FL_FFlag.allowinterrupt);}
			if ( FrameIsEndJump() ) {ActionSet("neutral");}
			
			ApproachSpeedX(0, FighterVar("deceleration"));
			break;
		
		case("attack0c"): // -------------------------------------------------
			if ( FrameIsStartJump() )
			{
				FighterFlagSet(FL_FFlag.standing | FL_FFlag.inmotion);
				FighterFlagClear(FL_FFlag.crouching | FL_FFlag.air);
			}
			
			if ( FrameIsJump(3) ) {FighterFlagClear(FL_FFlag.allowinterrupt);}
			
			if ( FrameIsJump(10) ) // Hitbox
			{
				HitboxEnable(0);
				HitboxRect(0, 60, 48, 168, 152);
			}
			if ( FrameIsJump(13) ) {HitboxReset();}
			
			if ( FrameIsJump(26) ) {FighterFlagSet(FL_FFlag.allowinterrupt);}
			if ( FrameIsEndJump() ) {ActionSet("neutral");}
			
			ApproachSpeedX(0, FighterVar("deceleration"));
			break;
		
		case("crouch-attack0a"):
		//case("crouch-attack0b"):
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
		
		case("crouch-attack0b"): // -------------------------------------------------
			if ( FrameIsStartJump() )
			{
				FighterFlagSet(FL_FFlag.crouching | FL_FFlag.inmotion);
				FighterFlagClear(FL_FFlag.standing | FL_FFlag.air);
			}
			
			if ( FrameIsJump(3) ) {FighterFlagClear(FL_FFlag.allowinterrupt);}
			
			if ( FrameIsJump(10) ) {AddSpeedX(10);}
			
			if ( FrameIsJump(25) ) {FighterFlagSet(FL_FFlag.allowinterrupt);}
			if ( FrameIsEndJump() ) {ActionSet("crouch");}
			
			ApproachSpeedX(0, FighterVar("deceleration"));
			break;
		
		// ======================================================================
		
		case("special0a"): // -------------------------------------------------
			if ( FrameIsStartJump() )
			{
				FighterFlagSet(FL_FFlag.standing | FL_FFlag.inmotion);
				FighterFlagClear(FL_FFlag.crouching | FL_FFlag.air);
			}
			
			if ( FrameIsJump(3) ) {FighterFlagClear(FL_FFlag.allowinterrupt);}
			
			if ( FrameIsJump(8) ) {AddSpeedX(15);}
			
			if ( FrameIsJump(25) ) {FighterFlagSet(FL_FFlag.allowinterrupt);}
			if ( FrameIsEndJump() ) {ActionSet("neutral");}
			
			ApproachSpeedX(0, FighterVar("deceleration"));
			break;
		
		// ======================================================================
		
		case("dash-attack0a"):
		case("dash-attack0b"):
		case("dash-attack0c"): // -------------------------------------------------
			if ( FrameIsStartJump() )
			{
				FighterFlagSet(FL_FFlag.standing | FL_FFlag.inmotion);
				FighterFlagClear(FL_FFlag.crouching | FL_FFlag.air);
			}
			
			if ( FrameIsJump(3) ) {FighterFlagClear(FL_FFlag.allowinterrupt);}
			
			if ( FrameIsJump(16) ) // Hitbox
			{
				HitboxEnable(0);
				HitboxRect(0, 20, 20, 120, 180);
			}
			if ( FrameIsJump(20) ) {HitboxReset();}
			
			if ( FrameIsJump(34) ) {FighterFlagSet(FL_FFlag.allowinterrupt);}
			if ( FrameIsEndJump() ) {ActionSet("neutral");}
			
			ApproachSpeedX(2, FighterVar("deceleration"));
			break;
	}
}


