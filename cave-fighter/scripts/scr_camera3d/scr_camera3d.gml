/// @desc

function Camera3D() constructor
{
	viewlocation = [0, 0, 0];
	viewforward = [0, -1, 0];
	viewright = [1, 0, 0];
	viewup = [0, 0, 1];
	viewdistance = 0;
	
	width = 480;
	height = 270;
	fieldofview = 50;
	znear = 1;
	zfar = 100;
	
	matproj = Mat4();
	matview = Mat4();
	
	function SetupCamera(_w, _h, _fov, _znear, _zfar)
	{
		width = 480;
		height = 270;
		fieldofview = _fov;
		znear = _znear;
		zfar = _zfar;
	}
	
	function UpdateMatView()
	{
		var fwrd = viewforward;
		var rght = viewright;
		var up = viewup;
		var loc = viewlocation;
		var d = viewdistance;
		
		//fwrd[1] = -fwrd[1];
		//loc[1] = -loc[1];
		
		matview = matrix_build_lookat(
			loc[0]-d, loc[1]-d, loc[2]-d,
			loc[0]+fwrd[0], loc[1]+fwrd[1], loc[2]+fwrd[2],
			up[0], up[1], up[2]
			);
		
		matproj = matrix_build_projection_perspective_fov(
			fieldofview, width/height, znear, zfar);
		
		//matview = matrix_multiply(Mat4ScaleXYZ(1, -1, 1), matview);
	}
	
	function SetLocation(_x, _y, _z)
	{
		viewlocation[0] = _x;
		viewlocation[1] = _y;
		viewlocation[2] = _z;
	}
	
	function PanLocation(_x, _y, _z)
	{
		viewlocation[0] += _x;
		viewlocation[1] += _y;
		viewlocation[2] += _z;
	}
	
	function SetDistance(_dist)
	{
		viewdistance = _dist;	
	}
	
	function SetViewForward(_dirx, _diry, _dirz)
	{
		var mag = point_distance_3d(0,0,0, _dirx, _diry, _dirz);
		viewforward[0] = _dirx / mag;
		viewforward[1] = _diry / mag;
		viewforward[2] = _dirz / mag;
		
		CrossProduct3dNormalized_ref(viewforward, viewup, viewright);
	}
	
	function PanDistance(_dist)
	{
		viewdistance += _dist;	
	}
	
	function LookAt(_x, _y, _z)
	{
		SetViewForward(
			_x - viewlocation[0],
			_y - viewlocation[1],
			_z - viewlocation[2]
			);
	}
}
