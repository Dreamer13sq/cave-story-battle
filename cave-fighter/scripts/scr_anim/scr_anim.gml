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
	
	var f, boneindex, i;
	
	f = 0;
	repeat(framecount)
	{
		framemats = array_create(bonecount);
		
		boneindex = 0;
		repeat(bonecount)
		{
			i = 0;
			repeat(16)
			{
				framemats[@ boneindex*16+i] = buffer_read(b, buffer_f32);
				i++;
			}
			boneindex++;
		}
		
		out[@ f] = framemats;
		f++;
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