/// @desc

vb = LoadVertexBuffer("test.vb", HEADER.vbf_pnct);

z = 0;
zrot = 0;

CAMERA3D.SetLocation(2, -4, 2);
CAMERA3D.LookAt(0, 0, 0);

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

vb_grid = CreateGridVB(16, 1);

