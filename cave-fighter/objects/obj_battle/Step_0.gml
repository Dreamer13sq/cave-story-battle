/// @desc

fighter.Update(battlespeed);
world.Update(battlespeed);

viewlocation[0] += LevKeyHeld(KeyCode.D, KeyCode.A);
viewlocation[2] += LevKeyHeld(KeyCode.W, KeyCode.S);
viewzrot += LevKeyHeld(KeyCode.Q, KeyCode.E);

//viewlocation[0] += LevKeyHeld(vk_right, vk_left);
//viewlocation[2] += LevKeyHeld(vk_up, vk_down);
viewdistance -= LevMouseWheel() * 10;

viewforward = matrix_transform_vertex(
	matrix_multiply(Mat4Rotate(viewxrot,0,0), Mat4Rotate(0,0,viewzrot)),
	0, -1, -0.1
	);

var _camvalstate = [
	window_get_width(), window_get_height(),
	viewdistance,
	viewforward[0], viewforward[1], viewforward[2], 
	viewlocation[0], viewlocation[1], viewlocation[2], 
];

// Only update if camera values have changed
if (!array_equals(_camvalstate, cameravaluestate))
{
	matproj = matrix_build_projection_perspective_fov(
	    fieldofview, //50 * pi / 180.0,
	    window_get_width() / window_get_height(),
	    znear,
	    zfar
	);
	
	cameraeyeposition = [
		viewlocation[0] - viewforward[0] * viewdistance,
		viewlocation[1] - viewforward[1] * viewdistance,
		viewlocation[2] - viewforward[2] * viewdistance,
	];

	matview = matrix_build_lookat(
		cameraeyeposition[0],
		cameraeyeposition[1],
		cameraeyeposition[2],
		viewlocation[0],
		viewlocation[1],
		viewlocation[2],
		0, 0, 1
	);

	// Fix Y-flip
	matview = matrix_multiply(Mat4ScaleXYZ(1, -1, 1), matview);
	
	cameravaluestate = _camvalstate;
}

stylemode ^= keyboard_check_pressed(KeyCode.O);

