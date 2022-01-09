/// @desc

var ts = 1;

if infinitedash {fighter.dashmeter = fighter.dashmetermax;}
if infinitepower {fighter.PowerAdd(2);}

fighter.Update(ts);

// Update Entity
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
	LevKeyHeld(VKey.d, VKey.a) * 5,
	-LevKeyHeld(VKey.e, VKey.q) * 2,
	LevKeyHeld(VKey.w, VKey.s) * 5
	);

if (lookat)
{
	CAMERA3D.LookAt(0, 0, 100);
}

CAMERA3D.UpdateMatView();

// Update Particles
var ll = ll_particle;
var nd = ll.headnode, ndnext;
while (nd)
{
	ndnext = nd.nodenext;
	
	nd.Update(ts);
	if (nd.nodeinert) {ll.RemoveNode(nd);}
	
	nd = ndnext;
}


