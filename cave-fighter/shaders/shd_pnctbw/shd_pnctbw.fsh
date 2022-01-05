//
// Simple passthrough fragment shader
//
varying vec2 v_uv;
varying vec4 v_color;
varying vec3 v_nor;

void main()
{
	vec3 l = normalize(vec3(1.0, -1.0, 2.0));
	float dp = dot(v_nor, l);
	
	vec2 uv = vec2( clamp(v_uv.x*dp, 0.0, 1.0), v_uv.y);
	vec4 outcolor = texture2D( gm_BaseTexture, uv );
	
    gl_FragColor = outcolor;
}
