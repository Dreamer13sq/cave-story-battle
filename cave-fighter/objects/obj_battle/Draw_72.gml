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

shader_reset();
gpu_pop_state();

