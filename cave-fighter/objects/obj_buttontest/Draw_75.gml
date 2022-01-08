/// @desc 

if debug
{
	draw_text(16, 64, [fighter.x, fighter.y])
	draw_text(16, 80, ll_battleentity.nodecount)

	var yy = 96;
	var i = 1;
	repeat(20)
	{
		draw_text(16, yy, ll_battleentity.nodelist[i]); yy += 12;
		i++;
	}
	yy += 16;
	draw_text(16, yy, ll_battleentity.headnode); yy += 12;
	draw_text(16, yy, ll_battleentity.tailnode); yy += 12;
}

layout.Draw();
