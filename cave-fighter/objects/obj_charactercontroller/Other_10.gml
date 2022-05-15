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
	FighterController();
	CheckCommands();
	
	if (bufferedactionstep > 0)
	{
		if (fighter.FighterFlagGet(FL_FFlag.allowinterrupt))
		{
			bufferedactionstep = 0;
			fighter.ActionSet(bufferedaction);
		}
		else
		{
			bufferedactionstep--;
		}
	}
	
	if (bufferedactionstep == 0)
	{
		bufferedaction = "";
		bufferedactionindex = 0xFF;
		bufferedactionstep = 0;	
	}
	
	if (icommandframes[icommandsindex] == buffertimetrigger)
	{
		printf("-----");
	}
	
	
}

function FighterController()
{
	var _inmotion = fighter.FighterFlagGet(FL_FFlag.inmotion);
	var _allowinterrupt = fighter.FighterFlagGet(FL_FFlag.allowinterrupt);
	
	// On Ground
	if ( !fighter.FighterFlagGet(FL_FFlag.air) )
	{
		if (_allowinterrupt)
		{
			// Crouching
			if (IHeld(InputIndex.down))
			{
				if ( !fighter.FighterFlagGet(FL_FFlag.crouching) )
				{
					fighter.ActionSet("crouching");	
				}
			}
			else
			{
				if ( fighter.FighterFlagGet(FL_FFlag.crouching) )
				{
					fighter.ActionSet("standing");	
				}
			}
			
			// Not Crouching
			if ( !fighter.FighterFlagGet(FL_FFlag.crouching) )
			{
				// Walk
				//fighter.speedvec[0] += IHeld(InputIndex.right)? fighter.walkforwardspeed: 0;
				//fighter.speedvec[0] -= IHeld(InputIndex.left)? fighter.walkbackspeed: 0;
				
				if (!_inmotion)
				{
					if ( IHeld(InputIndex.right) )
					{
						fighter.ActionSet("walk", false)	
						//fighter.ApproachSpeedX(fighter.walkforwardspeed, 1);
					}
					else if (IHeld(InputIndex.left))
					{
						fighter.ActionSet("walkback", false)
						//fighter.ApproachSpeedX(-fighter.walkbackspeed, 1);
					}
					else
					{
						fighter.ActionSet("neutral", false);
						//fighter.ApproachSpeedX(0, 1);
					}
				}
				
				// Jump
				if (IPressed(InputIndex.up))
				{
					fighter.ActionSet("jumpsquat");
				}
			}
		}
	}
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
	
	var _fighterstate = fighter.fighterstate;
	var _end = bufferedaction == ""? _count: min(bufferedactionindex, _count);
	
	for (var s = 0; s < _end; s++)
	{
		// Compare state
		if ( (sequences[s][1] & _fighterstate) != sequences[s][1] )
		{
			continue;
		}
		
		seq = sequences[s][0];
		seqlength = array_length(seq);
		commandoffset = icommandsindex;
		lastcommandframe = 0;
		
		parse = "";
		
		// Work backwards from final sequence input
		for (var i = seqlength-1; i >= 0; i--)
		{
			// Time between buttons
			if (icommandframes[commandoffset] > buffertimechain)
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
			if 0
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
					
					//if ( fighter.FighterFlagGet(FL_FFlag.allowinterrupt) )
					{
						bufferedaction = sequencedefs[s][2];
						bufferedactionstep = bufferedactiontime;
						bufferedactionindex = s;
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

