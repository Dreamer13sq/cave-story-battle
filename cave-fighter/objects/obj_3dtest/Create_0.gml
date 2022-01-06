/// @desc

event_user(0);

x = -1;
y = 0;
z = 0;
zrot = 0;
zoffset = 0;

CAMERA3D.SetLocation(0, 4, 1);
lookatvec = [0,0,1];

vb = LoadVertexBuffer("test.vb", HEADER.vbf_pnct);
vbx = LoadVBX("sue/model.vbx", HEADER.vbf_pnctbw);
poseset = {}
LoadFighterPoses("sue/pose/", poseset);
matpose = Mat4ArrayFlat(200);

posekey = -1;
activepose = -1;

vb_grid = CreateGridVB(160, 1/10);

pos = 0;
posmax = array_length(activepose);
posspeed = 1.0;

SetPose(variable_struct_get_names(poseset)[0])
