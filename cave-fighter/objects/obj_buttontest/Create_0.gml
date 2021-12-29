/// @desc

show_debug_overlay(true);

x = 0;
y = 0;

input = new InputManager();

inputhistorycount = 16;
inputhistoryindex = 0;
inputhistory = array_create(inputhistorycount);

// entry = [input, frames_elapsed]

input.DefineInputKey(InputIndex.right, VKey.right);
input.DefineInputKey(InputIndex.up, VKey.up);
input.DefineInputKey(InputIndex.left, VKey.left);
input.DefineInputKey(InputIndex.down, VKey.down);
input.DefineInputKey(InputIndex.a, VKey.z);
input.DefineInputKey(InputIndex.b, VKey.x);
input.DefineInputKey(InputIndex.c, VKey.c);
input.DefineInputKey(InputIndex.dash, VKey.space);
input.DefineInputKey(InputIndex.start, VKey.enter);
input.DefineInputKey(InputIndex.select, VKey.shift);

inputname = [
	"neutral",
	"right", "upright", "up", "upleft", 
	"left", "downleft", "down", "downright",
	"A", "B", "C", "dash"
	];

for (var i = 0; i < inputhistorycount; i++)
{
	inputhistory[i] = [0, 0];
}

function AppendHistory(inputcmd)
{
	inputhistoryindex = (inputhistoryindex+1) mod inputhistorycount;
	
	var entry = inputhistory[inputhistoryindex];
	entry[@ 0] = inputcmd;
	entry[@ 1] = 0;
}

floory = 200;

fighter = new Fighter();
fighter.x = 200;
fighter.y = 0;
fighter.Runner = Fighter_Quote_Runner;
fighter.inputmgr = input;

infinitedash = 1;
