/*
	Used for fighter models
*/

attribute vec3 in_Position;	// (x,y,z)
attribute vec3 in_Normal;	// (nx,ny,nz)
attribute vec4 in_Colour;	// (r,g,b,a)
attribute vec2 in_TextureCoord;	// (u,v)
attribute vec4 in_Bone;	// (b1,b2,b3,b4)
attribute vec4 in_Weight;	// (w1,w2,w3,w4)

varying vec3 v_pos;
varying vec3 v_nor;
varying vec4 v_color;
varying vec2 v_uv;

uniform float u_zoffset;
uniform float u_forwardsign;
uniform mat4 u_matpose[200];

void main()
{
	mat4 u_matview = gm_Matrices[MATRIX_VIEW];
	mat4 u_matproj = gm_Matrices[MATRIX_PROJECTION];
	mat4 u_mattran = gm_Matrices[MATRIX_WORLD];
	
	// Attributes --------------------------------------------------------
    vec4 vertexpos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
	vec4 normal = vec4( in_Normal.x, in_Normal.y, in_Normal.z, 0.0);
	
	// Weight & Bones ----------------------------------------------------
	mat4 m = mat4(0.0);
	for (int i = 0; i < 4; i++)
	{m += (u_matpose[ int(in_Bone[i]) ]) * in_Weight[i];}
	
	vertexpos = m * vertexpos;
	normal = m * normal;
	
	vertexpos.y *= -1.0;
	
	v_pos = vertexpos.xyz;
	v_nor = (normal * u_mattran).xyz;
	v_color = in_Colour;
    v_uv = in_TextureCoord;
	
	u_mattran[1][1] *= 0.02;
	
    gl_Position = (u_matproj * u_matview * u_mattran) * vertexpos;
	float side = (gl_Position.x * 0.1);
	
	gl_Position.z = (gl_Position.z + u_zoffset) * 0.1;
    
}
