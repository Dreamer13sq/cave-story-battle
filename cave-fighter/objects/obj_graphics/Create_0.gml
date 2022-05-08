/// @desc

function ShaderData(shd) constructor
{
	shaderhandle = shd;
	name = shader_get_name(shd);
	
	uniformhandles = ds_map_create();
	
	function Clean()
	{
		ds_map_destroy(uniformhandles);
	}
	
	// Returns uniform handle for shader
	function UniformHandle(handlekey)
	{
		if (!ds_map_exists(uniformhandles, handlekey))
		{
			uniformhandles[? handlekey] = shader_get_uniform(shaderhandle, handlekey);	
			if (uniformhandles[? handlekey] == -1)
			{
				uniformhandles[? handlekey] = shader_get_sampler_index(shaderhandle, handlekey);		
			}
			printf("%s[%s]: %s", name, handlekey, uniformhandles[? handlekey]);
		}
		return uniformhandles[? handlekey];
	}
	
	// Uniform Setting ===================================================================
	
	function Uniform1f(handlekey, v0) {shader_set_uniform_f(UniformHandle(handlekey), v0);}
	function Uniform2f(handlekey, v0, v1) {shader_set_uniform_f(UniformHandle(handlekey), v0, v1);}
	function Uniform3f(handlekey, v0, v1, v2) {shader_set_uniform_f(UniformHandle(handlekey), v0, v1, v2);}
	function Uniform4f(handlekey, v0, v1, v2, v3) {shader_set_uniform_f(UniformHandle(handlekey), v0, v1, v2, v3);}
	function UniformXf(handlekey, varray) {shader_set_uniform_f_array(UniformHandle(handlekey), varray);}
	
	function UniformMatrix4(handlekey, mat4) {shader_set_uniform_matrix_array(UniformHandle(handlekey), mat4);}
	function UniformSampler2D(handlekey, texture) {texture_set_stage(UniformHandle(handlekey), texture);}
}

activeshader = -1;
shaderdata = [];

// Create Shader data for all shaders
var _shd = 0;
var catcherr = 1;

while (catcherr)
{
	try {shader_get_name(_shd);}
	catch (catcherr) {catcherr = 0; break;}
	
	if (catcherr == 0) {break;}
	shaderdata[_shd] = new ShaderData(_shd);
	_shd++;
}

function ShaderSet(shd)
{
	if (activeshader == -1 || shader_current() != shd)
	{
		activeshader = shaderdata[shd];
		shader_set(shd);
	}
}

// ======================================================

formatmap = ds_map_create();

function DefineFormat(vbformat, key)
{
	formatmap[? key] = vbformat;
}

function Format(key) {return formatmap[? key];}


