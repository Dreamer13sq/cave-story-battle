/// @desc

var ts = 1;

if infinitedash {fighter.dashmeter = fighter.dashmetermax;}

fighter.Update(ts);

var ll = ll_battleentity;
var nd = ll.headnode, ndnext;
while (nd)
{
	ndnext = nd.nodenext;
	
	if (nd.nodeinert) {ll.RemoveNode(nd);}
	nd.Update(ts);
	if (nd.nodeinert) {ll.RemoveNode(nd);}
	
	nd = ndnext;
}

if fighter.x >= stagesize {fighter.x -= stagesize*2;}
if fighter.x <= -stagesize {fighter.x += stagesize*2;}

if (
	fighter.state == ST_Fighter.wait ||
	fighter.state == ST_Fighter.walkforward ||
	fighter.state == ST_Fighter.walkback
	)
{
	fighter.forwardsign = Pol(fighter.x <= 0);
}

CAMERA3D.PanLocation(
	LevKeyHeld(VKey.d, VKey.a) * 0.05,
	-LevKeyHeld(VKey.w, VKey.s) * 0.05,
	LevKeyHeld(VKey.e, VKey.q) * 0.02
	);


CAMERA3D.UpdateMatView();
