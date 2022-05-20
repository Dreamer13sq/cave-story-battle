/// @desc

enum InputIndex
{
	right, up, left, down,
	a, b, c, dash,
	start, select,
	
	mask_direction = (
		(1 << InputIndex.right) |
		(1 << InputIndex.up) |
		(1 << InputIndex.left) |
		(1 << InputIndex.down)
	),
	
	mask_button = (
		(1 << InputIndex.a) |
		(1 << InputIndex.b) |
		(1 << InputIndex.c) |
		(1 << InputIndex.dash)
	)
}

enum InputCmd
{
	forward, upforward, up, upback, 
	back, downback, down, downforward,
	a, b, c, dash,
	neutral,
	none,
	
	mask_direction = (
		(1 << InputCmd.forward) |
		(1 << InputCmd.upforward) |
		(1 << InputCmd.up) |
		(1 << InputCmd.upback) |
		(1 << InputCmd.back) |
		(1 << InputCmd.downback) |
		(1 << InputCmd.down) |
		(1 << InputCmd.downforward)
	),
	mask_neutral = (
		(1 << InputCmd.neutral)
	),
	mask_direction_neutral = InputCmd.mask_direction | InputCmd.mask_neutral,
	mask_button = (
		(1 << InputCmd.a) |
		(1 << InputCmd.b) |
		(1 << InputCmd.c) |
		(1 << InputCmd.dash)
	),
	
	FL_AnyDirection = 1 << 14,
	FL_ButtonLenient = 1 << 15,
}

function InputCmdChar(value)
{
	var out = "";
	for (var i = 0; i < 16; i++)
	{
		if (value & (1 << i))
		{
			switch(i)
			{
				case(InputCmd.forward):	out += "6"; break;
				case(InputCmd.upforward):	out += "9"; break;
				case(InputCmd.up):	out += "8"; break;
				case(InputCmd.upback):	out += "7"; break;
				case(InputCmd.back):	out += "4"; break;
				case(InputCmd.downback):	out += "1"; break;
				case(InputCmd.down):	out += "2"; break;
				case(InputCmd.downforward):	out += "3"; break;
				case(InputCmd.neutral):	out += "5"; break;
				
				case(InputCmd.a):	out += "A"; break;
				case(InputCmd.b):	out += "B"; break;
				case(InputCmd.c):	out += "C"; break;
				case(InputCmd.dash):	out += "D"; break;
			}
		}
	}
	
	return out;
}

