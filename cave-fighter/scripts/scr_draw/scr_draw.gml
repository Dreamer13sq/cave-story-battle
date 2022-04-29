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

function U_Fighter_SetShear(camposvec, gameposvec, characterposvec, xshearstrength, yshearstrength)
{
	var m = matrix_build_identity();
	var xx = point_distance(characterposvec[0], 0, gameposvec[0], 0) /
		point_distance(camposvec[0], camposvec[1], gameposvec[0], gameposvec[1]);
	var yy = point_distance(characterposvec[1], characterposvec[2], gameposvec[1], gameposvec[2]) /
		point_distance(camposvec[1], camposvec[2], gameposvec[1], gameposvec[2]);
	
	m[4] = xx * xshearstrength * sign(characterposvec[0]-gameposvec[0]);
	m[8] = yy * yshearstrength *-sign(characterposvec[2]-gameposvec[2]);
	
	shader_set_uniform_matrix_array(HEADER.shd_fighter_u_matshear, m);
	return m;
}
