//
// Simple passthrough fragment shader
//

// Passed from Vertex Shader
varying vec2 v_uv;
varying vec4 v_color;

void main()
{
    gl_FragColor = v_color * texture2D( gm_BaseTexture, v_uv );
	//gl_FragColor.a = v_color.a;
}

