/// @desc

var xx = 400, xxx;
var yy = 20;
var index, entry;

for (var i = 0; i < icommandcount; i++)
{
	index = Modulo(icommandsindex-i, icommandcount);
	entry = icommands[index];
	
	xxx = xx;
	for (var j = 0; j < 16; j++)
	{
		if (entry & (1 << j))
		{
			draw_sprite(spr_inputcmd, j, xxx, yy);
			xxx += 16;
		}
	}
	
	DrawText(xx-20, yy, icommands[index]);
	yy += 20;
}

