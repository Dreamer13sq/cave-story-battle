/*
*/

function LoadPoseArray(path, out)
{
	var b = buffer_load(path);
	if b == -1
	{
		show_debug_message("Error loading file at \"" + path + "\"");
		return;
	}
	
	var bdecomp = buffer_decompress(b);
	if (bdecomp > 0)
	{
		buffer_delete(b);
		b = bdecomp;
	}
	
	var framecount = buffer_read(b, buffer_u32);
	var bonecount = buffer_read(b, buffer_u32);
	var i = 0;
	var framemats;
	
	array_resize(out, framecount)
	
	printf([path, framecount, bonecount])
	
	for (var f = 0; f < framecount; f++)
	{
		framemats = array_create(bonecount);
		
		for (var boneindex = 0; boneindex < bonecount; boneindex++)
		{
			i = 0;
			repeat(16)
			{
				framemats[@ boneindex*16+i] = buffer_read(b, buffer_f32);
				i++;
			}
		}
		
		out[@ f] = framemats;
	}
	
	buffer_delete(b);
}

function LoadFighterPoses(rootpath, outstruct)
{
	rootpath = filename_dir(rootpath);
	
	var f = file_find_first(rootpath+"/*.pse", 0);
	var name;
	var index = 0;
	
	while (f != "")
	{
		name = filename_change_ext(f, "");
		
		outstruct[$ name] = [];
		LoadPoseArray("sue/pose/"+f, outstruct[$ name]);
		f = file_find_next();
		
		index += 1;
	}
	
	file_find_close();
}