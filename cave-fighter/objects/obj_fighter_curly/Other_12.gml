/// @desc Attack Defs

function FighterRunner()
{
	switch(actionkey)
	{
		default:
			printf("Action \"%s\" not found", actionkey);
			SetAction("neutral");
			break;
		
		case("neutral"): // -------------------------------------------------
			if ( FrameIsStart() )
			{
				SetStateFlag(FL_FFlag.standing | FL_FFlag.allowinterrupt);
				ClearStateFlag(FL_FFlag.inmotion | FL_FFlag.crouching | FL_FFlag.air);
			}
			
			ApproachSpeedX(0, FighterVar("deceleration"));
			break;
		
		case("crouch"): // -------------------------------------------------
			if ( FrameIsStart() )
			{
				SetStateFlag(FL_FFlag.crouching | FL_FFlag.allowinterrupt);
				ClearStateFlag(FL_FFlag.inmotion | FL_FFlag.standing | FL_FFlag.air);
			}
			
			ApproachSpeedX(0, FighterVar("deceleration"));
			break;
		
		case("jumpsquat"): // -------------------------------------------------
			if ( FrameIsStart() ) {SetStateFlag(FL_FFlag.inmotion);}
			if ( FrameIsEnd() ) 
			{
				SetAction("air-rise");
				SetSpeedY( FighterVar("jumpheight") );
			}
			break;
		
		case("jumpland"): // -------------------------------------------------
			if ( FrameIsStart() )
			{
				SetStateFlag(FL_FFlag.standing | FL_FFlag.allowinterrupt);
				ClearStateFlag(FL_FFlag.air);
			}
			ApproachSpeedX(0, FighterVar("deceleration"));
			if ( FrameIsEnd() ) {SetAction("neutral");}
			break;
		
		case("crouching"): // -------------------------------------------------
			if ( FrameIsStart() )
			{
				SetStateFlag(FL_FFlag.crouching | FL_FFlag.allowinterrupt | FL_FFlag.inmotion);
				ClearStateFlag(FL_FFlag.standing | FL_FFlag.air);
			}
			ApproachSpeedX(0, FighterVar("deceleration"));
			if ( FrameIsEnd() ) {SetAction("crouch");}
			break;
		
		case("standing"): // -------------------------------------------------
			if ( FrameIsStart() )
			{
				SetStateFlag(FL_FFlag.standing | FL_FFlag.allowinterrupt | FL_FFlag.inmotion);
				ClearStateFlag(FL_FFlag.crouching | FL_FFlag.air);
			}
			ApproachSpeedX(0, FighterVar("deceleration"));
			if ( FrameIsEnd() ) {SetAction("neutral");}
			break;
		
		case("air-rise"):
		case("air"): // -------------------------------------------------
			if ( FrameIsStart() )
			{
				SetStateFlag(FL_FFlag.air | FL_FFlag.allowinterrupt);
				ClearStateFlag(FL_FFlag.inmotion | FL_FFlag.standing | FL_FFlag.crouching);
			}
			break;
		
		case("block"): // -------------------------------------------------
			if ( FrameIsStart() )
			{
				SetStateFlag(FL_FFlag.standing | FL_FFlag.inmotion);
				ClearStateFlag(FL_FFlag.crouching | FL_FFlag.air);
			}
			
			if ( FrameIsEnd() ) {SetAction("neutral");}
			
			break;
		
		case("assist"): // -------------------------------------------------
			if ( FrameIsStart() ) 
			{
				SetStateFlag(FL_FFlag.inmotion);
				ClearStateFlag(FL_FFlag.allowinterrupt);
			}
			if ( FrameIsEnd() ) {SetAction("neutral");}
			break;
		
		// ======================================================================
		
		case("walk"): // -------------------------------------------------
			ApproachSpeedX(walkforwardspeed, 1);
			break;
		
		case("walkback"): // -------------------------------------------------
			ApproachSpeedX(-walkbackspeed, 1);
			break;
		
		case("dash"): // -------------------------------------------------
			if ( FrameIsStart() ) 
			{
				SetStateFlag(FL_FFlag.inmotion);
				SetSpeedX(dashforwardspeed);
			}
			
			ApproachSpeedX(dashforwardspeed, 1);
			
			if ( FrameIs(10) || FrameIsEnd() ) 
			{
				SetAction("neutral");
			}
			break;
		
		case("dashback"): // -------------------------------------------------
			if ( FrameIsStart() ) 
			{
				SetStateFlag(FL_FFlag.inmotion);
				SetSpeedX(-dashbackspeed);
			}
			
			ApproachSpeedX(-dashbackspeed, 1);
			
			if ( FrameIs(10) || FrameIsEnd() ) 
			{
				SetAction("neutral");
			}
			break;
		
		// ======================================================================
		
		case("attack0a"):
		case("attack0b"):
		case("attack0c"): // -------------------------------------------------
			if ( FrameIsStart() )
			{
				SetStateFlag(FL_FFlag.standing | FL_FFlag.inmotion);
				ClearStateFlag(FL_FFlag.crouching | FL_FFlag.air);
			}
			
			if ( FrameIs(3) ) {ClearStateFlag(FL_FFlag.allowinterrupt);}
			
			if ( FrameIs(17) ) {SetStateFlag(FL_FFlag.allowinterrupt);}
			if ( FrameIsEnd() ) {SetAction("neutral");}
			
			ApproachSpeedX(0, FighterVar("deceleration"));
			break;
		
		case("crouch-attack0a"):
		case("crouch-attack0b"):
		case("crouch-attack0c"): // -------------------------------------------------
			if ( FrameIsStart() )
			{
				SetStateFlag(FL_FFlag.crouching | FL_FFlag.inmotion);
				ClearStateFlag(FL_FFlag.standing | FL_FFlag.air);
			}
			
			if ( FrameIs(3) ) {ClearStateFlag(FL_FFlag.allowinterrupt);}
			
			if ( FrameIs(13) ) {SetStateFlag(FL_FFlag.allowinterrupt);}
			if ( FrameIsEnd() ) {SetAction("crouch");}
			
			ApproachSpeedX(0, FighterVar("deceleration"));
			break;
	}
}


