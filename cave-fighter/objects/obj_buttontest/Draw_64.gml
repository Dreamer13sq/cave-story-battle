/// @desc

var f = fighter;

var xx = 360;
var ysep = 20;
var hist = f.inputhistory;
var n = array_length(hist);
var _index = f.inputhistoryindex;

for (var i = 0; i < n; i++)
{
	draw_sprite(spr_inputcmd, BTNImage(hist[_index][0]), xx, 8+i*ysep-6);
	draw_text(xx+40, 4+i*ysep, hist[_index][1]);
	
	_index--;
	if _index < 0 {_index = n-1;}
}

var xx = 100, yy = 10, amt;
var btncolor, color1, color2;

for (var i = 0; i < 9; i++)
{
	btncolor = BTNColor(i);
	color1 = f.ButtonHeld(i)? btncolor: c_white;
	color2 = merge_color(btncolor, 0, 0.5);
	
	amt = max(0, 1-f.inputlastframe[i]/(SEQUENCEBUFFERFRAMES*2));
	
	draw_sprite_ext(spr_inputcmd_ring, BTNImage(i), xx, yy, 1, 1, 0, btncolor, amt);
	draw_sprite_ext(spr_inputcmd, BTNImage(i), xx, yy,
		1, 1, 0, merge_color(f.ButtonHeld(i)? color2: c_dkgray, color1, amt), 1);
	
	xx += 24;
}

// Health -------------------------------------------------------
var spr = spr_meter_health;
var xx = 52, yy = 16, ww = HEALTHWIDTH, hh = sprite_get_height(spr);
var amt1 = f.healthprovisional/f.healthmetermax;
var amt2 = f.healthmeterold/f.healthmetermax;
var amt3 = f.healthmeter/f.healthmetermax;
draw_sprite_stretched(spr, 0, xx+2, yy+2, ww, hh);
draw_sprite_stretched(spr, 1, xx, yy, ww, hh);
draw_sprite_stretched(spr, 2, xx, yy, ww*amt1, hh);
draw_sprite_stretched(spr, 3, xx, yy, ww*amt2, hh);
draw_sprite_stretched(spr, 4, xx, yy, ww*amt3, hh);

// Dash -------------------------------------------------------
var a = 0;
var amt1 = f.dashprovisional;
var amt2 = f.dashmeterold;
var amt3 = f.dashmeter;
var amtmax = f.dashmetermax;
var n = f.dashstockcount;
var spr = spr_meter_dash;
var xx = 52, yy = 40, ww = amtmax/n, hh = sprite_get_height(spr);
var sgn = 1;

for (var i = 0; i < n; i++)
{
	// Backdrop
	DrawSpriteW(spr, 0, xx+2, yy+2, sgn*ww); // Backdrop
	
	// Emptybar
	if ( !BoolStep(f.dashstockflash[i], 6) && f.DashStock() > i )
		{DrawSpriteW(spr, 2, xx, yy, sgn*ww);}
	else
		{DrawSpriteW(spr, 1, xx, yy, sgn*ww);}
	
	// Recharging (Purple)
	DrawSpriteW(spr, 3, xx, yy, sgn*clamp(amt1-a, 0, ww));
	
	// Recently used (White)
	if ( BoolStep(f.dashmeterflash, 6) )
	{
		DrawSpriteW(spr, 4, xx, yy, sgn*clamp(amt2-a, 0, ww));
	}
	
	// Real Value (Blue)
	DrawSpriteW(spr, 5, xx, yy, sgn*clamp(amt3-a, 0, ww));
	
	xx += sgn*(ww+2);
	a += ww;
}

// Power -------------------------------------------------------
var a = 0;
var amtmax = f.powermetermax;
var amt2 = f.powermeterold;
var amt3 = amt2 mod amtmax;
var n = f.powerstockcount;
var spr = spr_meter_power;
var xx = 16, yy = 270-32, ww = amtmax, hh = sprite_get_height(spr);
var sgn = 1;
var lvl = f.powermeter div f.powermetermax;
var lvlold = f.powermeterold div f.powermetermax;

var s = "Lv"+string(amt2 div amtmax)+"/"+string(n);
DrawText(xx+2, yy+2-2, s, c_dkgray);
DrawText(xx, yy-2, s);

xx += 64;

// Backdrop
DrawSpriteW(spr, 0, xx+2, yy+2, sgn*ww); // Backdrop
	
// Emptybar
DrawSpriteW(spr, 1, xx, yy, sgn*ww);
	
// Recharging (Purple)
//DrawSpriteW(spr, 3, xx, yy, sgn*clamp(amt1-a, 0, ww));

// Recently used (White)
if ( BoolStep(f.powermeterflash, 6) )
{
	if (lvlold > lvl)
	{
		DrawSpriteW(spr, 4, xx, yy, sgn*ww);	
	}
	else
	{
		DrawSpriteW(spr, 4, xx, yy, sgn*clamp(f.powermeterold mod amtmax, 0, ww));	
	}
}
	
// Real Value (Blue)
//if ( f.powermeter div amtmax > amt2 div amtmax )
{
	if (lvl == f.powerstockcount)
	{
		DrawSpriteW(spr, 5, xx, yy, sgn*ww);
	}
	else
	{
		DrawSpriteW(spr, 5, xx, yy, sgn*clamp(f.powermeter mod amtmax, 0, ww));	
	}
}

