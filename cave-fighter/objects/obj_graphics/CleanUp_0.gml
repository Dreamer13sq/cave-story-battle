/// @desc

for (var i = 0; i < array_length(shaderdata); i++)
{
	shaderdata[i].Clean();	
}

// Delete formats
var k = ds_map_find_first(formatmap);
while (ds_map_exists(formatmap, k))
{
	vertex_format_delete(formatmap[? k]);	
	k = ds_map_find_next(formatmap, k);
}
ds_map_destroy(formatmap);

