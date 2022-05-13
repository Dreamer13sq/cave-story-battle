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

enum AEL
{
	noop,
	
	logic_if,
	logic_else,
	logic_not,
	logic_and,
	logic_or,
	logic_repeat,
	
	fighterflag_set,
	fighterflag_clear,
	fighterflag_jump,
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

var ss = @"

// Jab Loop -----------------------------------
#jabloop

FrameIs(4, #jabloop_hb1)
FrameIs(8, #jabloop_hb1)
FrameIs(12, #jabloop_hb1)
FrameIs(16, #jabloop_hb1)

FrameIs(6, #jabloop_hbclear)
FrameIs(10, #jabloop_hbclear)
FrameIs(14, #jabloop_hbclear)
FrameIs(18, #jabloop_hbclear)
return

#jabloop_hb1
HitboxEnable(0)
HitboxRect(0, 40, 40, 80, 80)
HitboxProperties(0, 10, 10, HB_MID)
return

#jabloop_hbclear
HitboxDisable(0)
return

";

function AEL_ReadString(s)
{
	var c = string_char_at(s, 1);
	
	// Variable
	if (c == "@")
	{
		var word = string_copy(s, 2, string_length(s)-1);
		switch(string_lower(word))
		{
			default:
				return variable_struct_get(self, word);
		}
		return variable_struct_get(self, );
	}
}

function ParseActionEventText(s)
{
	var n = string_length(s);
	var out = [];
	
	var c;
	var o;
	var word = "";
	var mode = 0;
	
	var labels = [];
	var args = [];
	var argpos = 0;
	
	var stringdelim;
	
	for (var i = 1; i <= n; i++)
	{
		c = string_char_at(s, i);
		o = ord(c);
		
		// Look for functions and labels
		if (mode == 0)
		{
			// Label
			if (c == "#")
			{
				word += c;
				i++;
				while ( i < n && string_ord_at(s, i) > 0x32 )
				{
					word += string_char_at(s, i);
					i++;
				}
				
				array_push(labels, [word, array_length(out)]);
			}
			// Word
			else if (string_ord_at(s, i) > 0x32)
			{
				word += c;
			}
			// Function Start
			else if (c == "(")
			{
				args = array_create(8);
				args[0] = word;
				argpos = 1;
				mode = 1;
				word = "";
			}
			// Comments
			else if (c == "/" && string_char_at(s, i+1) == "/")
			{
				while (i<n && ord(string_char_at(s, i)) >= 0x32)
				{
					i++;
				}
				word = "";
			}
		}
		// Parse function arguments
		else if (mode == 1)
		{
			// String
			if (c == "\"" || c == "'")
			{
				stringdelim = c;
				i++;
				
				while (i < n && string_char_at(s, i) != stringdelim)
				{
					word += string_char_at(s, i);
				}
				
				args[argpos] = word;
				argpos++;
			}
			// Label
			else if (c == "#")
			{
				i++;
				while (i < n && string_ord_at(s, i) > 0x32)
				{
					word += string_char_at(s, i);
				}
				i--;
				
				args[argpos] = word;
				argpos++;
			}
			// Number
			else if (
				( ord(c) >= ord("0") && ord(c) <= ord("9") ) ||
				ord(c) == ord(".")
				)
			{
				
			}
		}
		// 
		
		
	}
}

