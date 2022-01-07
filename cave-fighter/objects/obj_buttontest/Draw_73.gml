/// @desc Draw UI

gpu_push_state();
gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);

shader_set(shd_pct);
shader_set_uniform_f(HEADER.shd_pnctbw_u_zoffset, zoffset);

var f = fighter;

var xx = 360;
var ysep = 20;
var hist = f.inputhistory;
var n = array_length(hist);
var _index = f.inputhistoryindex;

// History
var xx = 440;
var yy = 4;

for (var i = 0; i < 16; i++)
{
	draw_sprite(spr_inputcmd, BTNImage(hist[_index][0]), xx, yy+i*ysep);
	//draw_text(xx+40, yy+2+i*ysep, hist[_index][1]);
	
	_index--;
	if _index < 0 {_index = n-1;}
}

// Input Display
var xx = 32, yy = 210, amt;
var btncolor, color1, color2;

for (var i = 0; i < 9; i++)
{
	btncolor = BTNColor(i);
	color1 = f.ButtonHeld(i)? btncolor: c_white;
	color2 = merge_color(0, btncolor, 0.8);
	
	amt = max(0, 1-f.inputlastframe[i]/(SEQUENCEBUFFERFRAMES*2));
	
	draw_sprite_ext(spr_inputcmd_ring, BTNImage(i), xx, yy, 1, 1, 0, btncolor, amt*amt);
	draw_sprite_ext(spr_inputcmd, BTNImage(i), xx, yy,
		1, 1, 0, merge_color(f.ButtonHeld(i)? color2: c_dkgray, color1, amt), 1);
	
	xx += 24;
}

// Health -------------------------------------------------------
var spr = spr_meter_health;
var xx = 52, yy = 8, ww = HEALTHWIDTH, hh = sprite_get_height(spr);
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
var xx = 52, yy = 32, ww = amtmax/n, hh = sprite_get_height(spr);
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

// Fighter Vars
var xx = fighter.x+stagesize, yy = floory-fighter.y
var xscale = fighter.forwardsign;
var yscale = 1;

if fighter.state == ST_Fighter.crouch {yscale = 0.5;}
if fighter.state == ST_Fighter.jumpsquat {yscale = 0.7;}
if fighter.state == ST_Fighter.leapsquat {yscale = 0.3;}

//draw_sprite_ext(spr_person, 0, xx, yy, xscale, yscale, 0, c_white, 1);
draw_text(xx, yy, ST_Fighter_GetName(fighter.state));
draw_text(xx, yy+20, fighter.frame);
draw_text(xx, yy+40, [fighter.xspeed, fighter.yspeed]);



shader_reset();
gpu_pop_state();

