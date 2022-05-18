/// @desc

draw_clear(0x221111);

gpu_push_state();
gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);
gpu_set_cullmode(cull_clockwise);

GRAPHICS.ShaderSet(shd_fighter);

GRAPHICS.activeshader.Uniform1f("u_usestandard", stylemode);
GRAPHICS.activeshader.UniformMatrix4("u_matproj", matproj);
GRAPHICS.activeshader.UniformMatrix4("u_matview", matview);

fighter.Render();

GRAPHICS.ShaderSet(shd_color);
GRAPHICS.activeshader.UniformMatrix4("u_matproj", matproj);
GRAPHICS.activeshader.UniformMatrix4("u_matview", matview);
world.Render();

gpu_set_cullmode(cull_noculling);
var hb, fx, fy;
fx = fighter.Position()[0];
fy = fighter.Position()[1];

for (var i = 0; i < 16; i++)
{
	hb = fighter.hitboxes[i];
	if (hb.active)
	{
		GRAPHICS.activeshader.UniformMatrix4("u_mattran", Mat4Transform(
			fx+hb.rect[0], 0, fy+hb.rect[1],
			-90,0,0, 
			1,1,1
			));
		draw_sprite_stretched_ext(
			spr_hitbox, 0, 0, 0, 
			abs(hb.rect[2]-hb.rect[0]), abs(hb.rect[1]-hb.rect[3]), 
			c_red, 1);
	}
	
}

shader_reset();
gpu_pop_state();

