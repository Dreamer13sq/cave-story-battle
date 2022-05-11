/// @desc

function IPressed(input) {return ipressed & (1 << input);}
function IHeld(input) {return iheld & (1 << input);}
function IReleased(input) {return ireleased & (1 << input);}

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




