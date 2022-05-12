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
			break;
		
		case("crouch"): // -------------------------------------------------
			if ( FrameIsStart() )
			{
				SetStateFlag(FL_FFlag.crouching | FL_FFlag.allowinterrupt);
				ClearStateFlag(FL_FFlag.inmotion | FL_FFlag.standing | FL_FFlag.air);
			}
			break;
		
		case("jumpsquat"): // -------------------------------------------------
			if ( FrameIsStart() ) {SetStateFlag(FL_FFlag.inmotion);}
			if ( FrameIsEnd() ) 
			{
				SetAction("air-rise");
				SetSpeedY( FighterVar("jumpheight") );
			}
			break;
		
		case("crouching"): // -------------------------------------------------
			if ( FrameIsStart() )
			{
				SetStateFlag(FL_FFlag.crouching | FL_FFlag.allowinterrupt);
				ClearStateFlag(FL_FFlag.inmotion | FL_FFlag.standing | FL_FFlag.air);
			}
			if ( FrameIsEnd() ) {SetAction("crouch");}
			break;
		
		case("standing"): // -------------------------------------------------
			if ( FrameIsStart() )
			{
				SetStateFlag(FL_FFlag.standing | FL_FFlag.allowinterrupt);
				ClearStateFlag(FL_FFlag.inmotion | FL_FFlag.crouching | FL_FFlag.air);
			}
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
			
			if ( FrameIsEnd() )
			{
				SetAction("neutral");
			}
			
			break;
		
		case("assist"): // -------------------------------------------------
			if ( FrameIsStart() ) {SetStateFlag(FL_FFlag.inmotion);}
			if ( FrameIsEnd() ) {ClearStateFlag(FL_FFlag.inmotion);}
			break;
		
		// ======================================================================
		
		case("dash"): // -------------------------------------------------
			if ( FrameIsStart() ) {SetStateFlag(FL_FFlag.inmotion);}
			if ( FrameIsEnd() ) {ClearStateFlag(FL_FFlag.inmotion);}
			break;
		
		// ======================================================================
		
		case("attack0a"):
		case("attack0b"):
		case("attack0c"): // -------------------------------------------------
			if ( FrameIsStart() )
			{
				SetStateFlag(FL_FFlag.standing | FL_FFlag.inmotion);
				ClearStateFlag(FL_FFlag.crouching | FL_FFlag.air | FL_FFlag.allowinterrupt);
			}
			
			if ( FrameIs(17) ) {SetStateFlag(FL_FFlag.allowinterrupt);}
			if ( FrameIsEnd() ) {SetAction("neutral");}
			break;
		
		case("crouch-attack0a"):
		case("crouch-attack0b"):
		case("crouch-attack0c"): // -------------------------------------------------
			if ( FrameIsStart() )
			{
				SetStateFlag(FL_FFlag.crouching | FL_FFlag.inmotion);
				ClearStateFlag(FL_FFlag.standing | FL_FFlag.air | FL_FFlag.allowinterrupt);
			}
			
			if ( FrameIs(13) ) {SetStateFlag(FL_FFlag.allowinterrupt);}
			if ( FrameIsEnd() ) {SetAction("crouch");}
			break;
	}
}


