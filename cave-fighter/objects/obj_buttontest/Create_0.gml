/// @desc

#macro BATTLE global.g_battle
BATTLE = self;

show_debug_overlay(true);

x = 0;
y = 0;

input = HEADER.playerinput[0];

CAMERA3D.SetLocation(0, 4, 1);
CAMERA3D.LookAt(0, 0, 1);
CAMERA3D.PanLocation(0, 0, 0);

floory = 200;
stagesize = 400;
zoffset = 0;

fighter = new Fighter_Sue();
fighter.x = 0;
fighter.y = 0;
fighter.inputmgr = input;

infinitedash = 0;

vb_grid = OpenVertexBuffer("grid.vb", HEADER.vbf_pct);

ll_battleentity = new EntityLL();
