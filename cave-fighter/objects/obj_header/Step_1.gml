/// @desc

if keyboard_check(vk_tab)
{
	if keyboard_check_pressed(VKey.R)
	{
		game_restart();
		return;
	}
}

if keyboard_check_pressed(vk_f4)
{
	window_set_fullscreen(!window_get_fullscreen());
}

if keyboard_check_pressed(vk_escape)
{
	if window_get_fullscreen()
	{
		window_set_fullscreen(false);
	}
}

CURRENT_FRAME++;
