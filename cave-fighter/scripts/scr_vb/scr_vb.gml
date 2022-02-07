/*
*/

function FetchVB(path, format)
{
	var _map = HEADER.vb_map;
	
	if ( !ds_map_exists(_map, path) )
	{
		_map[? path] = OpenVertexBuffer(path, format);
	}
	
	return _map[? path];
}

function FetchVBM(path, format)
{
	var _map = HEADER.vbm_map;
	
	if ( !ds_map_exists(_map, path) )
	{
		var vbm = new VBMData();
		OpenVBM(vbm, path, format);
		_map[? path] = vbm;
	}
	
	return _map[? path];
}

