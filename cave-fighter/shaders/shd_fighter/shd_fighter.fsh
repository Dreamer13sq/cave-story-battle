//
// Simple passthrough fragment shader
//
varying vec3 v_pos;
varying vec3 v_nor;
varying vec4 v_color;
varying vec2 v_uv;


uniform float u_tintparam[3]; // [strength, mid, exponent]
uniform vec3 u_tintcolor[3];

const float PI = 3.141592653589793;

float Ease(float x)
{
	return -(cos(PI * x) - 1.0) / 2.0;
}

void main()
{
	vec3 l = normalize(vec3(1.0, -1.0, 2.0));
	float dp = dot(v_nor, l);
	
	float lightvalue = v_uv.x*dp;
	vec2 uv = vec2( clamp(lightvalue, 0.0, 1.0), v_uv.y);
	vec4 c = texture2D( gm_BaseTexture, uv );
	float lum = ( min(min(c.r, c.g), c.b) + max(max(c.r, c.g), c.b) ) * 0.5;
	
	// Tint
	vec3 tintcolor[2];
	float tintamt = u_tintparam[0];
	float tintmid = 1.0-u_tintparam[1];
	float tintexp = u_tintparam[2];
	
	float tintease[2];
	tintease[0] = Ease(pow( clamp(lum/tintmid, 0.0, 1.0), tintexp));
	tintease[1] = Ease(pow( clamp((lum-tintmid)/(1.0-tintmid), 0.0, 1.0), tintexp));
	
	tintcolor[0] = mix(u_tintcolor[0], u_tintcolor[1], tintease[0]);
	tintcolor[1] = mix(u_tintcolor[1], u_tintcolor[2], tintease[1]);
	vec3 tintoutcolor = mix(tintcolor[0], tintcolor[1], float(lum >= tintmid));
	tintoutcolor = clamp(tintoutcolor, vec3(0.0), vec3(1.0));
	
	c.rgb = mix(c.rgb, tintoutcolor, tintamt);
	
	//c.rgb = mix( mix(u_tintcolor[0], u_tintcolor[1], float(v_pos.z < 0.7)), u_tintcolor[2], float(v_pos.z < 0.3));
	
    gl_FragColor = c;
}
