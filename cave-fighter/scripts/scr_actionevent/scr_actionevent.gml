/// @desc

enum ActionEventCommand
{
	noop = 0,
	
	action,
	
	fighterflag_enable,
	fighterflag_disable,
	
	hitbox_enable,
	hitbox_disable,
	hitbox_clear,
	hitbox_properties,
	
	hurtbox_enable,
	hurtbox_disable,
	hurtbox_clear,
	hurtbox_properties,
}

/*
	map of labels <actionkey, command line>
	
	Goto(label) jumps to label.
	
	Label def:
		#LABEL_NAME
	
	write fighter script where everything is a function
	THEN convert to an event command format
	
	ex:
	{
		#dash	goto MOTION_START_END
		#assist	goto MOTION_START_END
		
		#MOTION_START_END
		if ( FrameIsStart() ) {SetStateFlag(FFLAG_INMOTION);}
		if ( FrameIsEnd() ) {ClearStateFlag(FFLAG_INMOTION);}
		return
	}
*/

