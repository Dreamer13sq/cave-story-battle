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
		
		if (device == -1) {return;}
	}
	
	// Parse Inputs
	var lastheld = iheld;
	iheld = 0;
	
	var mapentry, n;
	for (var i = 0; i < array_length(padmap); i++)
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
	
	ipressed = iheld & (~lastheld);
	ireleased = (~iheld) & lastheld;
}

function Update()
{
	UpdateInput();
	
	var _inputcmd = 0;
	
	// Directional
	if ( ((ipressed & 0xF) != 0) || ((ireleased & 0xF) != 0) )
	{
		// No Direction Held
		if ( (iheld & 0xF) == 0)
		{
			_inputcmd |= 1 << InputCmd.neutral;
			icommanddirection = -1;
		}
		// At least one direction is held
		else
		{
			var dir = darctan2(
				Lev((iheld & (1 << InputIndex.up)), (iheld & (1 << InputIndex.down))),
				Lev((iheld & (1 << InputIndex.right)), (iheld & (1 << InputIndex.left)))
				);
			dir = Modulo(round(dir * 8 / 360), 8);
			
			// New Direction
			if (dir != icommanddirection)
			{
				icommanddirection = dir;
				_inputcmd |= 1 << (InputCmd.forward + icommanddirection);
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
		icommandsindex = (icommandsindex+1) mod icommandcount;
		icommands[icommandsindex] = _inputcmd;
	}
}

function DefineSequence(seqstring)
{
	seqstring = string_upper(seqstring);
	var c;
	for (var i = 0; i < c; i++)
	{
		c = string_char_at(seqstring, i);
		switch(c)
		{
			case("A"):
				
				break;
		}
	}
}



