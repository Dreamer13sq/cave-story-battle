/// @desc

location = [0,0,0];

mattran = Mat4();

vb = OpenVertexBuffer("world.vb", GRAPHICS.Format("color"));

function Update(ts)
{
	
}

function Render()
{
	GRAPHICS.ShaderSet(shd_color);
	
	GRAPHICS.activeshader.UniformMatrix4("u_mattran", mattran);
	
	vertex_submit(vb, pr_trianglelist, -1);
}

