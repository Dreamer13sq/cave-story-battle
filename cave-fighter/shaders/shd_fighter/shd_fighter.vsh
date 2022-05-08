/*
	Renders vbs with basic shading.
	
	Used by:
		obj_modeltest (world.vb)
		obj_demomodel_normal
		obj_demomodel_vbm
*/

const vec4 u_light = vec4(1000.0, -3200.0, 2000.0, 1.0);
const vec3 VEC3YFLIP = vec3(1.0, 1.0, 1.0);
const mat4 MAT4YCORRECT = mat4(
	1.0, 0.0, 0.0, 0.0,
	0.0, -1.0, 0.0, 0.0,
	0.0, 0.0, 1.0, 0.0,
	0.0, 0.0, 0.0, 1.0
);

// Vertex Attributes ----------------------------------------------------
attribute vec3 in_Position;	// (x,y,z)
attribute vec3 in_Normal;	// (nx,ny,nz)
attribute vec4 in_Color;	// (r,g,b,a)
attribute vec2 in_TextureCoord;	// (u,v)
attribute vec4 in_Bone;	// (b1,b2,b3,b4)
attribute vec4 in_Weight;	// (w1,w2,w3,w4)

// Passed to Fragment Shader -------------------------------------------
varying vec3 v_pos;
varying vec3 v_normal;
varying vec2 v_uv;
varying vec4 v_color;

varying vec3 v_dirtolight_cs;	// Used for basic shading
varying vec3 v_dirtocamera_cs;	// ^
varying vec3 v_normal_cs;

/// Uniforms, set in code. Per Draw Call -------------------------------
uniform mat4 u_matproj;
uniform mat4 u_matview;
uniform mat4 u_mattran;

uniform float u_zoffset;
uniform float u_forwardsign;
uniform mat4 u_matshear;
uniform mat4 u_matpose[200];

void main()
{
	// Attributes --------------------------------------------------------
    vec4 vertexpos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
	vec4 normal = vec4( in_Normal.x, in_Normal.y, in_Normal.z, 0.0);
	
	// Weight & Bones ----------------------------------------------------
	mat4 m = mat4(0.0);
	for (int i = 0; i < 4; i++)
	{m += (u_matpose[ int(in_Bone[i]) ]) * in_Weight[i];}
	
	vertexpos = m * vertexpos;
	normal = m * normal;
	
	// Varyings ----------------------------------------------------------
    v_color = clamp(in_Color, 0.0, 1.0);
    v_uv = vec2(in_TextureCoord.x, mod(in_TextureCoord.y, 1.0));
	//v_uv[1] = 1.0-v_uv[1];
	
	// Shading Variables ----------------------------------------------
	mat4 matViewTran = u_matview * u_mattran;
	
	vec3 vertexpos_cs = (matViewTran * vertexpos).xyz;
	v_dirtocamera_cs = vec3(0.0) - vertexpos_cs;
	
	vec3 lightpos_cs = (u_matview * vec4(u_light.xyz, 1.0)).xyz;
	v_dirtolight_cs = lightpos_cs + v_dirtocamera_cs;
	
	v_normal_cs = (matViewTran * normal).xyz;
	v_normal_cs = normalize(v_normal_cs);
	
	// Set draw position -------------------------------------------------
	
	/*
		Bless you, Chev.
		https://gamedev.stackexchange.com/questions/86960/mixing-perspective-and-orthographic-projections
	*/
	
	gl_Position = (u_matproj * u_matview * u_mattran * u_matshear) * vertexpos;
	gl_Position.z -= 0.1;
}

