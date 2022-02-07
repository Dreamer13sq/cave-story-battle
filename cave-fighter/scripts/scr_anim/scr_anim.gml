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
		
		i = 0;
		repeat(bonecount * 16)
		{
			framemats[@ i] = buffer_read(b, buffer_f16);
			i++;
		}
		
		out[@ f] = framemats;
		f++;
	}
	
	buffer_delete(b);
}

function LoadFighterPoses(rootpath, outstruct)
{
	rootpath = filename_dir(rootpath) + "/";
	
	var f = file_find_first(rootpath+"*.trk", 0);
	var name;
	var index = 0;
	
	while (f != "")
	{
		name = filename_change_ext(f, "");
		
		var trk = new TRKData();
		OpenTRK(trk, rootpath+f);
		outstruct[$ name] = trk;
		
		//LoadPoseArray("sue/pose/"+f, outstruct[$ name]);
		
		f = file_find_next();
		
		index += 1;
	}
	
	file_find_close();
}

enum FighterTintPreset
{
	none = 0, white, parry, dash, charge, charge2, red, shadow
}

function U_Fighter_SetTint_Preset(_preset, _strength=1.0)
{
	switch(_preset)
	{
		default:
			U_Fighter_SetTint(0);
			break;
		
		case(FighterTintPreset.white):
            U_Fighter_SetTint(_strength, 0.0, 1.0, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF);
            break;

        case(FighterTintPreset.parry):
                U_Fighter_SetTint(_strength, 0.1000, 1.0000, 0xF30006, 0xFF8856, 0xFFFFFF);
                break;

        case(FighterTintPreset.dash):
                U_Fighter_SetTint(_strength, 0.9500, 2.0000, 0x130001, 0xFF0002, 0xFFB2B2);
                break;

        case(FighterTintPreset.charge):
                U_Fighter_SetTint(_strength, 0.1600, 1.0000, 0x0200A1, 0x008BFF, 0xFFFFFF);
                break;

        case(FighterTintPreset.charge2):
                U_Fighter_SetTint(_strength, 0.0000, 1.0000, 0x0400B3, 0x008BFF, 0x000000);
                break;

        case(FighterTintPreset.red):
                U_Fighter_SetTint(_strength, 0.2000, 1.1000, 0x030034, 0x00C9FF, 0xFFFFFF);
                break;

        case(FighterTintPreset.shadow):
                U_Fighter_SetTint(_strength, 0.5000, 2.0000, 0x000000, 0x0E070F, 0x8DFF2B);
                break;
	}
}
