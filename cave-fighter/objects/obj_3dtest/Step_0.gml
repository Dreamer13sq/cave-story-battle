/// @desc

var lev = LevKeyHeld(VKey.right, VKey.left)
if lev != 0
{
	x += lev * 0.05;
	SetPose("walk")
}
else
{
	SetPose("idle0")
}

y += LevKeyHeld(VKey.up, VKey.down) * 0.1;
zrot += LevKeyHeld(VKey.e, VKey.q);

CAMERA3D.PanLocation(
	LevKeyHeld(VKey.d, VKey.a) * 0.1,
	LevKeyHeld(VKey.w, VKey.s) * 0.10,
	0
	);

CAMERA3D.LookAt(lookatvec[0], lookatvec[1], lookatvec[2]);
CAMERA3D.UpdateMatView();

pos = Modulo(pos+posspeed, posmax)
matpose = activepose[pos]

zoffset += LevKeyHeld(VKey.bracketRight, VKey.bracketLeft) * 0.1;

