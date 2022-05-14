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
		if ( FrameIsStartJump() ) {FighterFlagSet(FFLAG_INMOTION);}
		if ( FrameIsEndJump() ) {FighterFlagClear(FFLAG_INMOTION);}
		return
	}
*/

function AEL(varname)
{
	if (is_real(varname))
	{
		return varname;
	}
	
	var c = string_char_at(varname, 1);
	
	// Variable
	if (c == "@")
	{
		var word = string_copy(varname, 2, string_length(varname)-1);
		
		switch(word)
		{
			default: return variable_struct_get(self, word);
			
			case("FFLAG_STANDING"):	return FL_FFlag.standing;
			case("FFLAG_INTERRUPT"):	return FL_FFlag.allowinterrupt;
			case("FFLAG_INMOTION"):	return FL_FFlag.inmotion;
			case("FFLAG_CROUCHING"):	return FL_FFlag.crouching;
			case("FFLAG_AIR"):	return FL_FFlag.air;
		}
	}
	// Label
	else
	{
		return varname;
	}
}

function ParseActionEventText(outarray, outmap, s)
{
	var n = string_length(s);
	
	var c;
	var o;
	var word = "";
	var mode = 0;
	
	var args = [];
	var argpos = 0;
	
	var stringdelim;
	var activelabel = "";
	var activelabelhit;
	
	for (var i = 1; i <= n; i++)
	{
		c = string_char_at(s, i);
		o = ord(c);
		
		// Look for functions and labels
		if (mode == 0)
		{
			// Comments
			if (c == "/" && string_char_at(s, i+1) == "/")
			{
				while (i<n && (string_ord_at(s, i) >= 0x20))
				{
					i++;
				}
				word = "";
			}
			// Label
			else if (c == "#")
			{
				word = "";
				i++;
				c = string_char_at(s,i);
				o = ord(c);
				
				if (c == "#")
				{
					i++;
					c = string_char_at(s,i);
					o = ord(c);
					activelabelhit = true;
				}
				else
				{
					activelabelhit = false;
				}
				
				while ( 
					i < n && (
						(o >= ord("0") && o <= ord("9")) ||
						(o >= ord("A") && o <= ord("Z")) ||
						(o >= ord("a") && o <= ord("z")) ||
						c == "_" || c == "-"
						)
					)
				{
					word += c;
					i++;
					c = string_char_at(s,i);
					o = ord(c);
				}
				i--;
				
				if (activelabelhit)
				{
					word = activelabel + word;
				}
				else
				{
					activelabel = word;
				}
				activelabelhit = false;
				
				//array_push(labels, [word, array_length(outarray)]);
				outmap[? word] = array_length(outarray);
				printf("Label: %s", [word, array_length(outarray), activelabel])
				word = "";
			}
			// Function Start
			else if (c == "(")
			{
				args = array_create(8);
				args[0] = word;
				argpos = 1;
				word = "";
				mode = 1;
			}
			// Word
			else if (o > 0x30)
			{
				word += c;
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
				
				word = "";
				while (i < n && string_char_at(s, i) != stringdelim)
				{
					word += string_char_at(s, i);
					i++;
				}
				
				args[argpos] = word;
				argpos++;
			}
			// Label
			else if (c == "#")
			{
				word = "";
				i++;
				c = string_char_at(s,i);
				o = ord(c);
				
				if (c == "#")
				{
					word += activelabel;
					i++;
					c = string_char_at(s,i);
					o = ord(c);
				}
				
				while ( 
					i < n && (
						(o >= ord("0") && o <= ord("9")) ||
						(o >= ord("A") && o <= ord("Z")) ||
						(o >= ord("a") && o <= ord("z")) ||
						c == "_" || c == "-"
						)
					)
				{
					word += c;
					i++;
					c = string_char_at(s,i);
					o = ord(c);
				}
				i--;
				
				args[argpos] = word;
				argpos++;
			}
			// Var
			else if (c == "@")
			{
				word = c;
				i++;
				c = string_char_at(s,i);
				o = ord(c);
				
				while ( 
					i < n && (
						(o >= ord("0") && o <= ord("9")) ||
						(o >= ord("A") && o <= ord("Z")) ||
						(o >= ord("a") && o <= ord("z")) ||
						c == "_" 
						)
					)
				{
					word += c;
					i++;
					c = string_char_at(s,i);
					o = ord(c);
				}
				i--;
				
				args[argpos] = word;
				argpos++;
			}
			// Number
			else if ( (ord(c) >= ord("0") && ord(c) <= ord("9")) || c=="." || c=="-" )
			{
				word = "";
				while (i < n && ( (ord(c) >= ord("0") && ord(c) <= ord("9")) || c=="." || c=="-" ))
				{
					word += c;
					i++;
					c = string_char_at(s, i);
				}
				i--;
				
				args[argpos] = real(word);
				argpos++;
			}
			// Function End
			else if (c == ")")
			{
				array_push(outarray, args);
				mode = 0;
				word = "";
				
				printf(args)
			}
		}
	}
}


