/// @desc

if (device != -1)
{
	var lev;
	var deadzone = 0.2;
	
	lev = gamepad_axis_value(device, gp_axislh);
	if (abs(lev) >= deadzone) {fighter.zrot += lev*3;}
	
	lev = gamepad_axis_value(device, gp_axisrh);
	if (abs(lev) >= deadzone) {obj_battle.viewzrot += lev*2;}
	
	lev = gamepad_axis_value(device, gp_axisrv);
	if (abs(lev) >= deadzone) {obj_battle.viewxrot -= lev*2;}
	
	if (gamepad_button_check(device, gp_shoulderl)) {obj_battle.viewdistance *= 1.01;}
	if (gamepad_button_check(device, gp_shoulderlb)) {obj_battle.viewdistance /= 1.01;}
	
	if (gamepad_button_check_pressed(device, gp_shoulderr)) {fighter.palindex = Modulo(fighter.palindex-1, fighter.palcount);}
	if (gamepad_button_check_pressed(device, gp_shoulderrb)) {fighter.palindex = Modulo(fighter.palindex+1, fighter.palcount);}
}

