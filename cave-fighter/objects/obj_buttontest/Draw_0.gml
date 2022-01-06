/// @desc

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

