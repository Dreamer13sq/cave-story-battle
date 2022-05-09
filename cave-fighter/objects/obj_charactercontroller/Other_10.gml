/// @desc

function UpdateInput()
{
	// Find Device
	if (device == -1)
	{
		for (var i = 0; i < 32; i++)
		{
			if (
				gamepad_button_check_pressed(i, gp_face1) ||
				gamepad_button_check_pressed(i, gp_face2) ||
				gamepad_button_check_pressed(i, gp_face3) ||
				gamepad_button_check_pressed(i, gp_face4)
			)
			{
				device = i;
				printf("Device Found!");
				break;
			}
		}
	}
	
	// Parse Inputs
	var lastheld = iheld;
	iheld = 0;
	
	var mapentry, n;
	for (var i = 0; i < array_length(padmap); i++)
	{
		// Key
		mapentry = keymap[i];
		n = array_length(mapentry);
		for (var j = 0; j < n; j++)
		{
			if ( keyboard_check(mapentry[j]) )
			{
				iheld |= 1 << i;
			}
		}
		
		// Pad
		if (device != -1)
		{
			mapentry = padmap[i];
			n = array_length(mapentry);
			for (var j = 0; j < n; j++)
			{
				if ( gamepad_button_check(device, mapentry[j]) )
				{
					iheld |= 1 << i;
				}
			}
		}
	}
	
	ipressed = iheld & (~lastheld);
	ireleased = (~iheld) & lastheld;
}

function Update()
{
	UpdateInput();
	
	// Update command frames
	for (var i = 0; i < icommandcount; i++)
	{
		icommandframes[i] = min(icommandframes[i]+1, 255);	
	}
	
	var _inputcmd = 0;
	
	// Directional
	if ( ((ipressed & 0xF) != 0) || ((ireleased & 0xF) != 0) )
	{
		// No Direction Held
		if ( (iheld & 0xF) == 0)
		{
			if ( (iheld & 0xF0) == 0 )
			{
				_inputcmd |= 1 << InputCmd.neutral;
			}
			icommanddirection = -1;
		}
		// At least one direction is held
		else
		{
			var _xlev = Lev((iheld & (1 << InputIndex.right)), (iheld & (1 << InputIndex.left)));
			var _ylev = Lev((iheld & (1 << InputIndex.up)), (iheld & (1 << InputIndex.down)));
			
			var dir = darctan2(_ylev, _xlev);
			
			dir = Modulo(round(dir * 8 / 360), 8);
			
			// New Direction
			if (dir != icommanddirection)
			{
				if (_xlev==0 && _ylev==0)
				{
					icommanddirection = -1;
					_inputcmd |= 1 << InputCmd.neutral;
				}
				else
				{
					icommanddirection = dir;
					_inputcmd |= 1 << (InputCmd.forward + dir);
				}
			}
		}
	}
	
	// Buttons
	if ( ((ipressed) != 0) || ((ireleased) != 0) )
	{
		if (iheld & (1 << InputIndex.a)) {_inputcmd |= 1 << InputCmd.a;}
		if (iheld & (1 << InputIndex.b)) {_inputcmd |= 1 << InputCmd.b;}
		if (iheld & (1 << InputIndex.c)) {_inputcmd |= 1 << InputCmd.c;}
		if (iheld & (1 << InputIndex.dash)) {_inputcmd |= 1 << InputCmd.dash;}
		
		if (icommanddirection != -1)
		{
			_inputcmd |= 1 << (InputCmd.forward + icommanddirection);
		}
	}
	
	// Append
	if (_inputcmd != 0)
	{
		icommandsindex = (icommandsindex-1);
		if (icommandsindex < 0) {icommandsindex = icommandcount-1;}
		
		icommands[icommandsindex] = _inputcmd;
		icommandframes[icommandsindex] = 0;
	}
	
	// Check Commands
	CheckCommands();
	
	if (icommandframes[icommandsindex] == buffertimetrigger)
	{
		printf("-----");
	}
	
	
}

function ParseSequence(seqstring)
{
	/*
		==KEY==
		A, B, C, D : Buttons
		1, 2, 3, 4, 5, 6, 7, 8, 9 : Directions (Numpad notation)
		
		~ : Direction-Lenient (Valid as long as any of the given directions are inputted)
		
	*/
	var c;
	var outseq = [0];
	var index = 0;
	var _newbundle = false;
	var n = string_length(seqstring);
	
	seqstring = string_upper(seqstring);
	
	// Check chars
	for (var i = 0; i < n; i++)
	{
		c = string_char_at(seqstring, i+1);
		switch(c)
		{
			// Directions
			case("1"): outseq[@ index] |= 1 << InputCmd.downback; break;
			case("2"): outseq[@ index] |= 1 << InputCmd.down; break;
			case("3"): outseq[@ index] |= 1 << InputCmd.downforward; break;
			case("4"): outseq[@ index] |= 1 << InputCmd.back; break;
			case("5"): outseq[@ index] |= 1 << InputCmd.neutral; break;
			case("6"): outseq[@ index] |= 1 << InputCmd.forward; break;
			case("7"): outseq[@ index] |= 1 << InputCmd.upback; break;
			case("8"): outseq[@ index] |= 1 << InputCmd.up; break;
			case("9"): outseq[@ index] |= 1 << InputCmd.upforward; break;
			
			// Buttons
			case("A"): outseq[@ index] |= 1 << InputCmd.a; break;
			case("B"): outseq[@ index] |= 1 << InputCmd.b; break;
			case("C"): outseq[@ index] |= 1 << InputCmd.c; break;
			case("D"): outseq[@ index] |= 1 << InputCmd.dash; break;
			
			// Logics -----------------------------------------------
			
			// New Bundle
			case(" "): _newbundle = true; break;
			// Direction Input Leniency
			case("~"): outseq[@ index] |= InputCmd.FL_AnyDirection; break;
			// Direction Input Leniency
			case("*"): outseq[@ index] |= InputCmd.FL_ButtonLenient; break;
		}
		
		// Make new bundle
		if (_newbundle && outseq[@ index] != 0)
		{
			index++;
			array_push(outseq, 0);
		}
		
		_newbundle = false;
	}
	
	return outseq;
}

function CheckCommands()
{
	// Max Buffer Time
	if (icommandframes[icommandsindex] > buffertimetrigger)
	{
		return;
	}
	
	var _count = array_length(sequences);
	var commandoffset;
	var entry, entry_direction, entry_button;
	var seq, seqlength, seqstep, seqstep_direction, seqstep_button;
	var lastcommandframe = 0;
	var parse;
	
	for (var s = 0; s < _count; s++)
	{
		seq = sequences[s];
		seqlength = array_length(seq);
		commandoffset = icommandsindex;
		lastcommandframe = 0;
		
		parse = "";
		
		// Work backwards from final sequence input
		for (var i = seqlength-1; i >= 0; i--)
		{
			// Time between buttons
			if (icommandframes[commandoffset]-lastcommandframe > buffertimechain)
			{
				break;
			}
			
			lastcommandframe = icommandframes[commandoffset];
			
			seqstep = seq[i];
			seqstep_direction = seqstep & InputCmd.mask_direction;
			seqstep_button = seqstep & InputCmd.mask_button;
			
			entry = icommands[commandoffset];
			entry_direction = entry & InputCmd.mask_direction;
			entry_button = entry & InputCmd.mask_button;
			
			// Skip neutral if found and not needed
			if ( (seqstep & InputCmd.mask_neutral) == 0)
			{
				while( (entry_button == 0) && (entry & InputCmd.mask_neutral) != 0 )
				{
					commandoffset = Modulo(commandoffset+1, icommandcount);
					
					if (commandoffset == icommandsindex)
					{
						entry = 0;
						entry_direction = 0;
						entry_button = 0;
						break;	
					}
					
					entry = icommands[commandoffset];
					entry_direction = entry & InputCmd.mask_direction;
					entry_button = entry & InputCmd.mask_button;
				}
			}
			
			// Skip direction inputs if wildcard (?)
			if ( (seqstep & InputCmd.FL_ButtonLenient) == 0)
			{
				while( (entry & InputCmd.mask_button) != 0 )
				{
					commandoffset = Modulo(commandoffset+1, icommandcount);
					
					if (commandoffset == icommandsindex)
					{
						entry = 0;
						entry_direction = 0;
						entry_button = 0;
						break;	
					}
					
					entry = icommands[commandoffset];
					entry_direction = entry & InputCmd.mask_direction;
					entry_button = entry & InputCmd.mask_button;
				}
			}
			
			// Advance to next step if conditions met
			if ( 
				(
					// Step requires a direction AND direction matches
					( (seqstep_direction == 0) || (seqstep_direction == entry_direction)) ||
					// Step requires a direction AND direction is present
					( (seqstep & InputCmd.FL_AnyDirection) != 0 && (seqstep_direction & entry_direction) != 0)
				) &&
				// Step requires a button AND correct button is pressed
				( (seqstep_button == 0) || (entry_button == seqstep_button) ) &&
				// Step requires a direction AND neutral is present
				( (seqstep & InputCmd.mask_neutral) == 0 || ((entry & seqstep) & InputCmd.mask_neutral) != 0)
			)
			{
				commandoffset = Modulo(commandoffset+1, icommandcount);
				
				parse = InputCmdChar(entry) + parse;
				
				// Command Complete
				if (i == 0)
				{
					commandexecuted = stringf("%s %s frames [%s]", sequencedefs[s][1], lastcommandframe, parse);
					printf(commandexecuted);
					icommandframes[icommandsindex] = buffertimechain;
					
					if (fighter.allowinterrupt)
					{
						fighter.SetAnimation(sequencedefs[s][2]);
					}
					
					return;
				}
				
				parse = " " + parse;
				
				// Skip next command if lenient direction
				if ( (seqstep & InputCmd.FL_AnyDirection) != 0 )
				{
					entry = icommands[commandoffset];
					entry_direction = entry & InputCmd.mask_direction;
					entry_button = entry & InputCmd.mask_button;
					
					while( (entry_button == 0) && (seqstep_direction & entry_direction) != 0 )
					{
						commandoffset = Modulo(commandoffset+1, icommandcount);
					
						if (commandoffset == icommandsindex)
						{
							entry = 0;
							entry_direction = 0;
							entry_button = 0;
							break;	
						}
					
						entry = icommands[commandoffset];
						entry_direction = entry & InputCmd.mask_direction;
						entry_button = entry & InputCmd.mask_button;
					}
				}
				
			}
			// Wrong Buttons
			else
			{
				break;	
			}
			
		}
	}
}

