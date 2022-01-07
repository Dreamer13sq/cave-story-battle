/// @desc 

function SetPose(key)
{
	if (!variable_struct_exists(poseset, key))
	{
		show_debug_message("Unknown key \"" + key + "\"")
		return;
	}
	
	if (key != posekey)
	{
		posekey = key;
		activepose = poseset[$ key];
		pos = 0;
		posmax = array_length(activepose);
	}
}
