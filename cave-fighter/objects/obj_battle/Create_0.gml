/// @desc

event_user(0);

fighter = instance_create_depth(x, y, 0, obj_fighter);
controller = instance_create_depth(x, y, 0, obj_charactercontroller);
world = instance_create_depth(x, y, 0, obj_world_vb);

viewlocation = [0,0,100];
viewforward = Vec3Normalized([0,-1,-0]);
viewdistance = 500;
viewxrot = 0;
viewzrot = 0;
cameraeyeposition = [0,0,80];

znear = 10;
zfar = 10000;

matproj = Mat4();
matview = Mat4();

cameravaluestate = [];

stylemode = 0;

