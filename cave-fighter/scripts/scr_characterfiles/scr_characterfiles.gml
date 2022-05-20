/// @desc

function CharFolder() constructor
{
	path = "";
	
	files_vbm = ds_map_create();
	files_trk = ds_map_create();
	files_pal = ds_map_create();
	
	names_vbm = array_create(0);
	names_trk = array_create(0);
	names_pal = array_create(0);
	
	// ====================================================================
	
	function _Get(_map, _names, outarray)
	{
		var n = array_length(_names);
		for (var i = 0; i < n; i++)
		{
			array_push(outarray, _map[? _names[i]])
		}
		return n;
	}
	
	function _GetName(_names, index)
	{
		return _names[index];
	}
	
	function GetVBMs(outarray) {return _Get(files_vbm, names_vbm, outarray);}
	function GetTRKs(outarray) {return _Get(files_trk, names_trk, outarray);}
	function GetPALs(outarray) {return _Get(files_pal, names_pal, outarray);}
	
	function GetVBMName(index) {return _GetName(names_vbm, index);}
	function GetTRKName(index) {return _GetName(names_trk, index);}
	function GetPALName(index) {return _GetName(names_pal, index);}
	
	// ====================================================================
	
	function Clear()
	{
		// Free VBMs
		var _map = files_vbm, k = ds_map_find_first(_map);
		while (ds_map_exists(_map , k))
		{
			VBMFree(_map[? k]);
			k = ds_map_find_next(_map, k);
		}
		ds_map_clear(_map);
		array_resize(names_vbm, 0);
		
		// Free TRKs
		var _map = files_trk, k = ds_map_find_first(_map);
		while (ds_map_exists(_map , k))
		{
			TRKFree(_map[? k]);
			k = ds_map_find_next(_map, k);
		}
		ds_map_clear(_map);
		array_resize(names_trk, 0);
		
		// Free Sprites
		var _map = files_pal, k = ds_map_find_first(_map);
		while (ds_map_exists(_map , k))
		{
			sprite_delete(_map[? k]);
			k = ds_map_find_next(_map, k);
		}
		ds_map_clear(_map);
		array_resize(names_pal, 0);
	}
	
	function Free()
	{
		Clear();
		
		ds_map_destroy(files_vbm);
		ds_map_destroy(files_trk);
		ds_map_destroy(files_pal);
	}
	
	function _SearchFolder_Rec(_pathmap, rootpath, depth=0)
	{
		rootpath = filename_dir(rootpath) + "/";
		//printf(rootpath)
		
		// Find subfolders
		if (depth > 0)
		{
			var dirname = file_find_first(rootpath+"*", fa_directory); // WILDCARDS ARE IMPORTATN!!
			var subpaths = [];
			var n = 0;
			
			while (dirname != "")
			{
				if (directory_exists(rootpath+dirname+"/"))
				{
					array_push(subpaths, rootpath+dirname+"/");
					n++;
				}
				
				dirname = file_find_next();
			}
			file_find_close();
			
			// Search Subfolders
			for (var i = 0; i < n; i++)
			{
				_SearchFolder_Rec(_pathmap, subpaths[i], depth-1);
			}
		}
		
		// Get file paths
		var fname = file_find_first(rootpath+"*", 0);
		
		while (fname != "")
		{
			if (file_exists(rootpath+fname))
			{
				_pathmap[? fname] = rootpath+fname;
			}
			
			fname = file_find_next();
		}
	
		file_find_close();
	}
	
	function SearchFolder(rootpath, depth=0)
	{
		if (!directory_exists(rootpath))
		{
			printf("CharFiles::SearchFolder(): Invalid Path specified \"%s\"", rootpath);
			return -1;
		}
		
		var _pathmap = ds_map_create();
		
		Clear();
		
		// Find files
		_SearchFolder_Rec(_pathmap, rootpath, depth);
		
		// Load files
		var fname = ds_map_find_first(_pathmap);
		while (ds_map_exists(_pathmap, fname))
		{
			switch( string_lower(filename_ext(fname)) )
			{
				case(".vbm"):
					files_vbm[? fname] = new VBMData();
					array_push(names_vbm, fname);
					OpenVBM(files_vbm[? fname], _pathmap[? fname]);
					break;
				
				case(".trk"):
					files_trk[? fname] = new TRKData();
					array_push(names_trk, fname);
					OpenTRK(files_trk[? fname], _pathmap[? fname]);
					break;
				
				case(".png"):
					files_pal[? fname] = sprite_add(_pathmap[? fname], 1, 0, 0, 0, 0);
					array_push(names_pal, fname);
					printf(_pathmap[? fname] + " %s", files_pal[? fname]);
					break;
			}
			
			fname = ds_map_find_next(_pathmap, fname);
		}
		
		array_sort(names_vbm, true);
		array_sort(names_trk, true);
		array_sort(names_pal, true);
		
		ds_map_destroy(_pathmap);
		
		return 0;
	}
}

