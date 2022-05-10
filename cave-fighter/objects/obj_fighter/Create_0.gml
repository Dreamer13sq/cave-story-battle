/// @desc

event_user(0);	// Game Loop
event_user(1);	// Methods

state = 0;

characterfolder = new CharFolder();
if (characterfolder.SearchFolder("D:/GitHub/Cave-Story-Fighter/cave-fighter/datafiles/curly/", 3) == -1)
{
	characterfolder.SearchFolder("C:/Users/Dreamer/Documents/GitHub/Cave-Story-Fighter/cave-fighter/datafiles/curly/", 3)
}


trkarray = [];
trkcount = characterfolder.GetTRKs(trkarray);
trkindex = irandom(trkcount-1);
trkactive = trkarray[trkindex];
animkey = "";
allowinterrupt = true;

palarray = [];
palcount = characterfolder.GetPALs(palarray);
palindex = irandom(palcount-1);
palactive = palarray[palindex];

vbm = characterfolder.files_vbm[? characterfolder.GetVBMName(0)];

localpose = Mat4Array(200);
matpose = Mat4ArrayFlat(200);
mattran = Mat4();
matshear = Mat4();

location = [0,0,0];
zrot = 0;

playbackframe = 0;

image_speed = 0;

function FighterModel()
{
	
}



