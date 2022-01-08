/// @desc

#macro BATTLE global.g_battle
BATTLE = self;

show_debug_overlay(true);

x = 0;
y = 0;

dontflatten = 0;

lookat = false;

input = HEADER.playerinput[0];

CAMERA3D.SetLocation(0, 400, 100);
CAMERA3D.LookAt(0, 0, 100);

floory = 200;
stagesize = 400;
zoffset = 0;

fighter = new Fighter_Sue();
fighter.x = 0;
fighter.y = 0;
fighter.inputmgr = input;

vb_grid = OpenVertexBuffer("grid.vb", HEADER.vbf_pct);
vb_axisbox = OpenVertexBuffer("axisbox.vb", HEADER.vbf_pct);

ll_battleentity = new EntityLL();
ll_battleentity.name = "Battle LL";
ll_particle = new EntityLL();
ll_particle.name = "Particle LL";

infinitedash = 0;
debug = 0;

// Layout
layout = new Layout();
layout.SetPosXY(window_get_width()-240, 16, window_get_width()-16, 200);
event_user(1);
