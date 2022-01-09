/*
*/

function FetchVB(path, format)
{
	var _map = HEADER.vbmap;
	
	if ( !ds_map_exists(_map, path) )
	{
		_map[? path] = OpenVertexBuffer(path, format);
	}
	
	return _map[? path];
}

function FetchVBX(path, format)
{
	var _map = HEADER.vbxmap;
	
	if ( !ds_map_exists(_map, path) )
	{
		_map[? path] = OpenVBX(path, format);
	}
	
	return _map[? path];
}

