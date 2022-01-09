/// @desc

vertex_format_delete(vbf_pct);
vertex_format_delete(vbf_pnct);
vertex_format_delete(vbf_pnctbw);

var k, m;

m = vbmap;
k = ds_map_find_first(m);
while ( ds_map_exists(m, k) )
{
	vertex_delete_buffer(m[? k]);
	k = ds_map_find_next(m, k);
}

m = vbxmap;
k = ds_map_find_first(m);
while ( ds_map_exists(m, k) )
{
	VBXFree(m[? k]);
	delete m[? k];
	k = ds_map_find_next(m, k);
}
