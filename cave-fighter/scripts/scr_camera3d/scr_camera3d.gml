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
	matbillboard_yup = Mat4();
	matbillboard_zup = Mat4();
	
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
		
		matbillboard_zup = Mat4();
		array_copy(matbillboard_zup, 0, matview, 0, 16);
		matbillboard_zup[0] = 1;
		matbillboard_zup[1] = 0;
		matbillboard_zup[2] = 0;
		matbillboard_zup[4] = 0;
		matbillboard_zup[5] = 1;
		matbillboard_zup[6] = 0;
		matbillboard_zup[8] = 0;
		matbillboard_zup[9] = 0;
		matbillboard_zup[10] = 1;
		matbillboard_yup = matrix_multiply(Mat4Rotate(90, 0, 0), matbillboard_zup);
		
		//matview = matrix_multiply(Mat4ScaleXYZ(1, -1, 1), matview);
	}
	
	function GetLocationVec() 
	{
		return [
			viewlocation[0] - viewforward[0]*viewdistance,
			viewlocation[1] - viewforward[1]*viewdistance, 
			viewlocation[2] - viewforward[2]*viewdistance
			];
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
