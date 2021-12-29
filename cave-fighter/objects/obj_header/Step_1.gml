/// @desc

if keyboard_check(vk_tab)
{
	if keyboard_check_pressed(VKey.R)
	{
		game_restart()
		return;
	}
}

CURRENT_FRAME++;
