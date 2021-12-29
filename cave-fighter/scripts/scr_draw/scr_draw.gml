/// @desc

function DrawSpriteW(sprite, image, x, y, w)
{
	if (w >= 0)
	{
		draw_sprite_stretched(sprite, image, x, y, w, sprite_get_height(sprite));
	}
	else
	{
		draw_sprite_stretched(sprite, image, x+w, y, -w, sprite_get_height(sprite));
	}
}

function DrawText(x, y, text, color=c_white, alpha=1.0)
{
	draw_text_color(x, y, text, color, color, color, color, alpha);	
}
