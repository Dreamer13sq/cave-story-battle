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
	
	if 0
	for (var f = 0; f < framecount; f++)
	{
		framemats = array_create(bonecount);
		
		for (var boneindex = 0; boneindex < bonecount; boneindex++)
		{
			framemats[@ boneindex] = matrix_build_identity();
			i = 0;
			repeat(16)
			{
				framemats[@ boneindex][@ i] = buffer_read(b, buffer_f32);
				i++;
			}
		}
		
		out[@ f] = framemats;
	}
	else
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