//
// Simple passthrough vertex shader
//

// Vertex Attributes ----------------------------------------------------
attribute vec3 in_Position;	// (x,y,z)
attribute vec4 in_Color;	// (r,g,b,a)
attribute vec2 in_TextureCoord;	// (u,v)

// Passed to Fragment Shader -------------------------------------------
varying vec2 v_uv;
varying vec4 v_color;

/// Uniforms, set in code. Per Draw Call -------------------------------
uniform mat4 u_matproj;
uniform mat4 u_matview;
uniform mat4 u_mattran;

void main()
{
	// Attributes --------------------------------------------------------
    vec4 vertexpos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
	
	gl_Position = (u_matproj * u_matview * u_mattran) * vertexpos;
	
	v_uv = in_TextureCoord;
	v_color = in_Color;
}

