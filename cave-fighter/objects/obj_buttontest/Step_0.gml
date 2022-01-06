/// @desc

input.UpdateInput();
input.UpdateInputBuffers(1);

for (var i = 0; i < inputhistorycount; i++)
{
	inputhistory[i][1]++;	
}

if input.Pressed(InputIndex.right)
|| input.Pressed(InputIndex.up)
|| input.Pressed(InputIndex.left)
|| input.Pressed(InputIndex.down)
|| input.Released(InputIndex.right)
|| input.Released(InputIndex.up)
|| input.Released(InputIndex.left)
|| input.Released(InputIndex.down)
{
	var xlev = input.LevHeld(InputIndex.right, InputIndex.left);
	var ylev = -input.LevHeld(InputIndex.up, InputIndex.down);
	
	if xlev == 0 && ylev == 0
	{
		//AppendHistory(InputCmd.neutral);
	}
	else
	{
		var dir = point_direction(0, 0, xlev, ylev);
		dir *= (8/360);
		AppendHistory(InputCmd.forward + dir);
		//printf(dir)
	}
	
}

if input.Pressed(InputIndex.a) {AppendHistory(InputCmd.a);}
if input.Pressed(InputIndex.b) {AppendHistory(InputCmd.b);}
if input.Pressed(InputIndex.c) {AppendHistory(InputCmd.c);}
if input.Pressed(InputIndex.dash) {AppendHistory(InputCmd.dash);}

if infinitedash {fighter.dashmeter = fighter.dashmetermax;}

fighter.Update(1);

if fighter.x >= stagesize {fighter.x -= stagesize*2;}
if fighter.x <= -stagesize {fighter.x += stagesize*2;}

CAMERA3D.PanLocation(
	LevKeyHeld(VKey.d, VKey.a) * 0.1,
	LevKeyHeld(VKey.w, VKey.s) * 0.10,
	0
	);


CAMERA3D.UpdateMatView();
