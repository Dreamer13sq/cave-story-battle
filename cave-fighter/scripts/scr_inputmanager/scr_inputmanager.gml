/// @desc Struct used to manage and poll for inputs. 
/*
	See also: (Press F1 on or middle-click function name)
		scr_init()
*/

function InputManager() constructor
{
	static INPUTBUFFERMAX = 255;
	
	keymap = []; // [ [key, input], [key, input], ... ]
	padmap = []; // [ [pad, input], [pad, input], ... ]
	mousemap = []; // [ [mb, input], [mb, input], ... ]
	keymapsize = 0;
	padmapsize = 0;
	mousemapsize = 0;
	
	inputcount = 0;
	
	ipressed = 0;
	iheld = 0;
	ireleased = 0;
	ibuffer = array_create(32, INPUTBUFFERMAX); // holds time since last input press
	
	device = -1; // Device for controller input (-1 = no device)
	axissensitivity = 0.5; // Amount at which moving the stick will count as an input
	
	function Free()
	{
			
	}
	
	/// @arg inputindex,key,key,...
	function DefineInputKey()
	{
		var inputindex = argument[0];
		var entry;
		
		// for each key, add entry
		for (var i = 1; i < argument_count; i++)
		{
			if is_string(argument[i]) // string -> ord()
				{entry = [ord(argument[i]), inputindex];}
			else // already an ASCII value
				{entry = [argument[i], inputindex];}
			array_push(keymap, entry);
			keymapsize++;
		}
	}
	
	// For axes, use negative value for other direction.
	/*
		Ex:
			DefineInputPad(RIGHT, gp_axislh); // +x direction
			DefineInputPad(LEFT, -gp_axislh); // -x direction
	*/
	/// @arg inputindex,gpad_index,gpad_index,...
	function DefineInputPad()
	{
		var inputindex = argument[0];
		var entry;
		
		// for each input, add entry
		for (var i = 1; i < argument_count; i++)
		{
			// argument should always be a real value
			entry = [argument[i], inputindex];
			array_push(padmap, entry);
			padmapsize++;
		}
	}
	
	/// @arg inputindex,mb,mb,...
	function DefineInputMouse()
	{
		var inputindex = argument[0];
		var entry;
		
		// for each input, add entry
		for (var i = 1; i < argument_count; i++)
		{
			// argument should always be a real value
			entry = [argument[i], inputindex];
			array_push(mousemap, entry);
			mousemapsize++;
		}
	}
	
	function UpdateInput()
	{
		var map;
		var n;
		var entry;
		
		var _lastheld = iheld;
		
		//ipressed = 0;
		iheld = 0;
		//ireleased = 0;
		
		// iterate through keymap inputs
		map = keymap;
		n = keymapsize;
		for (var i = 0; i < n; i++)
		{
			entry = map[i];
			
			// Keyboard
			//if keyboard_check_pressed(entry[0]) {ipressed |= 1 << entry[1];}
			//if keyboard_check_released(entry[0]) {ireleased |= 1 << entry[1];}
			if keyboard_check(entry[0]) {iheld |= 1 << entry[1];}
		}
		
		// iterate through mousemap inputs
		map = mousemap;
		n = mousemapsize;
		for (var i = 0; i < n; i++)
		{
			entry = map[i];
			
			// Keyboard
			//if keyboard_check_pressed(entry[0]) {ipressed |= 1 << entry[1];}
			//if keyboard_check_released(entry[0]) {ireleased |= 1 << entry[1];}
			if mouse_check_button(entry[0]) {iheld |= 1 << entry[1];}
		}
		
		// Device exists
		if device != -1
		{
			map = padmap;
			n = padmapsize;
			
			// Gamepad
			for (var i = 0; i < n; i++)
			{
				entry = map[i];
				
				switch(entry[0])
				{
					// Buttons
					default:
						if gamepad_button_check(device, entry[0])
							{iheld |= 1 << entry[1];}
						break;
					
					// Axes (Positive)
					case(gp_axislh):
					case(gp_axislv):
					case(gp_axisrh):
					case(gp_axisrv):
						if gamepad_axis_value(device, entry[0]) >= axissensitivity
							{iheld |= 1 << entry[1];}
						break;
					// Axes (Negative)
					case(-gp_axislh):
					case(-gp_axislv):
					case(-gp_axisrh):
					case(-gp_axisrv):
						if gamepad_axis_value(device, -entry[0]) <= -axissensitivity
							{iheld |= 1 << entry[1];}
						break;
				}
				
				
			}
		}
		
		// Update held and released bit fields
		
		// ipressed = (inputs NOT held last time) AND (inputs held currently)
		ipressed = ~_lastheld & iheld;
		// ireleased = (inputs held last time) AND (inputs NOT held currently)
		ireleased = _lastheld & ~iheld;
	}
	
	function UpdateInputBuffers(ts=1)
	{
		for (var i = 0; i < 32; i++)
		{
			// input pressed
			if ipressed & (1 << i)
			{
				ibuffer[i] = 0;
			}
			// update buffer
			else if ibuffer[i] < INPUTBUFFERMAX
			{
				ibuffer[i] = min(ibuffer[i]+ts, INPUTBUFFERMAX);
			}
		}
	}
	
	// Input checking
	function Pressed(inputindex)
		{return (ipressed & (1 << inputindex)) != 0;}
	function Released(inputindex)
		{return (ireleased & (1 << inputindex)) != 0;}
	function Held(inputindex)
		{return (iheld & (1 << inputindex)) != 0;}
	function Buffered(inputindex, thresh)
		{return ibuffer[inputindex] <= thresh;}
	
	function PressedAny() {return ipressed != 0;}
	function ReleasedAny() {return ireleased != 0;}
	function HeldAny() {return iheld != 0;}
	
	// Returns -1, 0, or 1 based on active positive and negative inputs
	function LevPressed(pos_index, neg_index)
	{return ((ipressed & (1 << pos_index)) != 0) - ((ipressed & (1 << neg_index)) != 0);}
	function LevReleased(pos_index, neg_index)
	{return ((ireleased & (1 << pos_index)) != 0) - ((ireleased & (1 << neg_index)) != 0);}
	function LevHeld(pos_index, neg_index)
	{return ((iheld & (1 << pos_index)) != 0) - ((iheld & (1 << neg_index)) != 0);}
	
	// Resets buffer values
	function BufferClear(inputindex)
	{
		ibuffer[inputindex] = INPUTBUFFERMAX;
	}
	
	function ClearPress(inputindex) {ipressed &= ~(1 << inputindex);}
	
	// Sets gamepad device to read inputs from
	function SetDevice(_device) {device = _device;}
	// Returns current device for gamepad input. -1 if no device is set
	function GetDevice() {return device;}
	
	// Returns index of controller device where a button is pressed
	function PollDevice()
	{
		// For each possible device...
		for (var d = 0; d < 20; d++) // idk how many there are. Manual says maybe 20?
		{
			if gamepad_button_check(d, gp_face1)
			{
				return d;
			}
		}
		
		return -1;
	}
}

