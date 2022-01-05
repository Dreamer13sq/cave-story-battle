/// @desc

x += LevKeyHeld(VKey.d, VKey.a) * 0.1;
y += LevKeyHeld(VKey.w, VKey.s) * 0.1;
zrot += LevKeyHeld(VKey.e, VKey.q);

CAMERA3D.PanLocation(
	LevKeyHeld(vk_right, vk_left) * 0.1,
	LevKeyHeld(vk_up, vk_down) * 0.1,
	0
	);

CAMERA3D.LookAt(0, 0, 0.5);
CAMERA3D.UpdateMatView();

pos = Modulo(pos+posspeed, posmax)
matpose = poses[pos]
