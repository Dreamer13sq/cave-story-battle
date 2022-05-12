/// @desc

var xx = 400, xxx;
var yy = 10;
var index, entry;

for (var i = 0; i < icommandcount; i++)
{
	index = Modulo(icommandsindex+i, icommandcount);
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
	
	DrawText(xx-20, yy, icommandframes[index], (index == icommandsindex)? c_lime: c_white);
	
	yy += 16;
}

xx = 20;
yy = 240;
if 0
for (var i = 0; i < icommandcount; i++)
{
	DrawText(xx, yy, icommandframes[i], (i == icommandsindex)? c_lime: c_white);
	xx += 24;
}

DrawText(20, 220, bufferedactionstep);


