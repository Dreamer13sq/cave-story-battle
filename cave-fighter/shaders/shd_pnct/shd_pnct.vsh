//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;	// (x,y,z)
attribute vec3 in_Normal;	// (nx,ny,nz)
attribute vec4 in_Colour;	// (r,g,b,a)
attribute vec2 in_TextureCoord;	// (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

varying vec3 v_nor;

void main()
{
	mat4 u_matview = gm_Matrices[MATRIX_VIEW];
	mat4 u_matproj = gm_Matrices[MATRIX_PROJECTION];
	mat4 u_mattran = gm_Matrices[MATRIX_WORLD];
	
    vec4 object_space_pos = vec4( in_Position.x, -in_Position.y, in_Position.z, 1.0);
    gl_Position = (u_matproj * u_matview * u_mattran) * object_space_pos;
    
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
	v_nor = (vec4(in_Normal, 0.0) * gm_Matrices[MATRIX_WORLD]).xyz;

}
