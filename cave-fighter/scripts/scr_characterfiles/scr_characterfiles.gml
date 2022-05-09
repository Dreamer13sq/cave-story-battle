/// @desc

function CharFolder() constructor
{
	path = "";
	
	files_vbm = ds_map_create();
	files_trk = ds_map_create();
	files_pal = ds_map_create();
	
	// ====================================================================
	
	function _Get(_map, outarray)
	{
		var k = ds_map_find_first(_map);
		while (ds_map_exists(_map, k))
		{
			array_push(outarray, _map[? k]);	
			k = ds_map_find_next(_map, k);
		}
		return ds_map_size(_map);
	}
	
	function _GetName(_map, index)
	{
		var k = ds_map_find_first(_map);
		repeat(index)
		{
			k = ds_map_find_next(_map, k);	
		}
		return k;
	}
	
	function GetVBMs(outarray) {return _Get(files_vbm, outarray);}
	function GetTRKs(outarray) {return _Get(files_trk, outarray);}
	function GetPALs(outarray) {return _Get(files_pal, outarray);}
	
	function GetVBMName(index) {return _GetName(files_vbm, index);}
	function GetTRKName(index) {return _GetName(files_trk, index);}
	function GetPALName(index) {return _GetName(files_pal, index);}
	
	// ====================================================================
	
	function Clear()
	{
		// Free VBMs
		var _map = files_vbm, k = ds_map_find_first(_map);
		while (ds_map_exists(_map , k))
		{
			_map[k].Free();
			k = ds_map_find_next(_map, k);
		}
		
		// Free TRKs
		var _map = files_trk, k = ds_map_find_first(_map);
		while (ds_map_exists(_map , k))
		{
			_map[k].Free();
			k = ds_map_find_next(_map, k);
		}
		
		// Free Sprites
		var _map = files_pal, k = ds_map_find_first(_map);
		while (ds_map_exists(_map , k))
		{
			sprite_delete(_map[k]);
			k = ds_map_find_next(_map, k);
		}
	}
	
	function Free()
	{
		ds_map_destroy(files_vbm);
		ds_map_destroy(files_trk);
		ds_map_destroy(files_pal);
	}
	
	function _SearchFolder_Rec(_pathmap, rootpath, depth=0)
	{
		rootpath = filename_dir(rootpath) + "/";
		printf(rootpath)
		
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
					OpenVBM(files_vbm[? fname], _pathmap[? fname]);
					break;
				
				case(".trk"):
					files_trk[? fname] = new TRKData();
					OpenTRK(files_trk[? fname], _pathmap[? fname]);
					break;
				
				case(".png"):
					files_pal[? fname] = sprite_add(_pathmap[? fname], 1, 0, 0, 0, 0);
					printf(_pathmap[? fname] + " %s", files_pal[? fname]);
					break;
			}
			
			fname = ds_map_find_next(_pathmap, fname);
		}
		
		ds_map_destroy(_pathmap);
		
		return 0;
	}
}

