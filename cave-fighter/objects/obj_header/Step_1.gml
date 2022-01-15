/// @desc

if (lastwindowsize[0] != window_get_width() || lastwindowsize[1] != window_get_height())
{
	if (window_get_width() > 0 && window_get_height())
	{
		lastwindowsize[0] = window_get_width();
		lastwindowsize[0] = window_get_height();
		windowresized = true;
	
		surface_resize(application_surface, window_get_width(), window_get_height());
	}
}
else
{
	windowresized = false;
}

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

for (var i = 0; i < playerinputcount; i++)
{
	playerinput[i].UpdateInput();
	playerinput[i].UpdateInputBuffers(1);
}
