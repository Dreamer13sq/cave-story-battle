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

function CreateGridVB(count, cellsize)
{
	function __vert(vb, x, y, z, color)
	{
		vertex_position_3d(vb, x, y, z);
		vertex_color(vb, color, 1);
		vertex_texcoord(vb, 0, 0);
	}
	
	var vb = vertex_create_buffer();
	var w = cellsize * count;
	vertex_begin(vb, HEADER.vbf_pct);
	
	for (var i = -count; i <= count; i++)
	{
		if (i == 0)
		{
			__vert(vb, -w, i*cellsize, 0, c_red);	
			__vert(vb, w, i*cellsize, 0, c_red);	
			__vert(vb, i*cellsize, -w, 0, c_lime);	
			__vert(vb, i*cellsize, w, 0, c_lime);	
		}
		else
		{
			__vert(vb, -w, i*cellsize, 0, c_gray);	
			__vert(vb, w, i*cellsize, 0, c_gray);	
			__vert(vb, i*cellsize, -w, 0, c_gray);	
			__vert(vb, i*cellsize, w, 0, c_gray);		
		}
	}
	
	vertex_end(vb);
	return vb;
}

function U_Fighter_SetTint(strength=0, midposition=0.0, exponent=0.0, color0=0, color1=0, color2=0)
{
	shader_set_uniform_f_array(HEADER.shd_fighter_u_tintparam, 
		[strength, midposition, exponent]);
	shader_set_uniform_f_array(HEADER.shd_fighter_u_tintcolor, [
			color_get_red(color0)*.004, color_get_green(color0)*.004, color_get_blue(color0)*.004,
			color_get_red(color1)*.004, color_get_green(color1)*.004, color_get_blue(color1)*.004,
			color_get_red(color2)*.004, color_get_green(color2)*.004, color_get_blue(color2)*.004
		]);
}

enum FighterTintPreset
{
	none = 0, white, parry, dash, charge, charge2, red, shadow
}

function U_Fighter_SetTint_Preset(_preset, _strength=1.0)
{
	switch(_preset)
	{
		default:
			U_Fighter_SetTint(0);
			break;
		
		case(FighterTintPreset.white):
            U_Fighter_SetTint(_strength, 0.0, 1.0, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF);
            break;

        case(FighterTintPreset.parry):
                U_Fighter_SetTint(_strength, 0.1000, 1.0000, 0xF30006, 0xFF8856, 0xFFFFFF);
                break;

        case(FighterTintPreset.dash):
                U_Fighter_SetTint(_strength, 0.9500, 2.0000, 0x130001, 0xFF0002, 0xFFB2B2);
                break;

        case(FighterTintPreset.charge):
                U_Fighter_SetTint(_strength, 0.1600, 1.0000, 0x0200A1, 0x008BFF, 0xFFFFFF);
                break;

        case(FighterTintPreset.charge2):
                U_Fighter_SetTint(_strength, 0.0000, 1.0000, 0x0400B3, 0x008BFF, 0x000000);
                break;

        case(FighterTintPreset.red):
                U_Fighter_SetTint(_strength, 0.2000, 1.1000, 0x030034, 0x00C9FF, 0xFFFFFF);
                break;

        case(FighterTintPreset.shadow):
                U_Fighter_SetTint(_strength, 0.5000, 2.0000, 0x000000, 0x0E070F, 0x8DFF2B);
                break;
	}
}

