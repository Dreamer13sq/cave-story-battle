//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

varying vec3 v_nor;

void main()
{
	vec3 l = normalize(vec3(1.0, -1.0, 2.0));
	float dp = dot(v_nor, l);
	
    gl_FragColor = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	gl_FragColor.rgb *= dp;
}
