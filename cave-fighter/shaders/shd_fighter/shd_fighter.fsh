/*
	Renders vbs with stylistic shading.
	
	Params:
		vc[0] = Color AO
		vc[1] = Color Index
		vc[2] = Dot Product Strength
		vc[3] = ???
*/

// Constants
const float DP_EXP = 1.0;	// Higher values smooth(?), Lower values sharpen
const float SPE_EXP = 64.0;	// Higher values sharpen, Lower values smooth
const float RIM_EXP = 4.0;	// Higher values sharpen, Lower values smooth
const float EULERNUMBER = 2.71828;	// Funny E number used in logarithmic stuff

// Passed from Vertex Shader
varying vec2 v_uv_surface;
varying vec4 v_color;

varying vec3 v_dirtolight_cs;
varying vec3 v_dirtocamera_cs;
varying vec3 v_normal_cs;
varying float v_normaloffset;

// Uniforms passed in before draw call
//uniform vec4 u_drawmatrix[4]; // [alpha emission roughness rim colorblend[4] colorfill[4]]

uniform sampler2D u_texture;
uniform bool u_usestandard;

// =================================================================================================

float noise(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

// =================================================================================================

void Palette();
void Standard();

void main()
{
	if (!u_usestandard)
	{
		Palette();
	}
	else
	{
		Standard();
	}
	
	//gl_FragColor.rgb *= float(1.0-v_normaloffset);
}

void Palette()
{
	// Varyings -------------------------------------------------------
	// There's some error when normalizing in vertex shader. Looks smoother here
	vec3 n = normalize(v_normal_cs);		// Vertex Normal
	vec3 l = normalize(v_dirtolight_cs);	// Light Direction
	vec3 e = normalize(v_dirtocamera_cs);	// Camera Direction
	vec3 r = reflect(-l, n);				// Reflect Angle
	
	float AO = v_color.x;
	float COLORINDEX = v_color.y;
	float DPSTRENGTH = v_color.z;
	
	float shine = max(0.0, dot(e, r));	// Specular
	float dp = clamp(dot(n, l), 0.0, 1.0);	// Dot Product
	float fresnel = 1.0-max(0.0, dot(n, e));	// Fake Fresnel
	
	// 
	float lightvalue = mix(AO, AO * dp, DPSTRENGTH);
	vec2 uv = vec2(lightvalue, COLORINDEX);
	vec4 texcolor = texture2D(u_texture, uv);
	vec4 outcolor = vec4(texcolor.rgb, 1.0);
	vec3 ambient = vec3(0.8, 0.7, 1.0);
	
	// Specular
	float roughness = texcolor.a;
	float speamt = pow(roughness, 4.0);
	
	float specularamt = float( (shine+pow(fresnel*(2.0-roughness), 2.0)) > (1.0-(pow(roughness, 4.0)) * AO) ) * (1.0-pow(roughness, 0.5));
	vec3 specularcolor = (outcolor.rgb + (1.0-outcolor.rgb) * 0.1) + (pow(1.1-roughness, 32.0));
	//float anisotrophicamt = noise();
	
	outcolor.rgb += specularcolor * (
		specularamt *
		pow(2.0-length(outcolor.rgb), 2.0)
	);
	
	//outcolor.rgb = mix(outcolor.rgb*ambient, outcolor.rgb, clamp(pow(length(outcolor.rgb), 1.0), 0.0, 1.0) );
	
    gl_FragColor = outcolor;
}

void Standard()
{
	// Uniforms -------------------------------------------------------
	float alpha = 1.0;
	float emission = 0.0;
	float roughness = 0.3;
	float rim = 1.0;
	vec4 colorblend = vec4(1.0, 1.0, 1.0, 0.0);
	vec4 colorfill = vec4(1.0, 1.0, 1.0, 0.0);
	
	float AO = v_color.x;
	float COLORINDEX = v_color.y;
	float DPSTRENGTH = v_color.z;
	float DPMIN = 0.0;
	float DPMAX = 1.0;
	
	// Varyings -------------------------------------------------------
	// There's some error when normalizing in vertex shader. Looks smoother here
	vec3 n = normalize(v_normal_cs);		// Vertex Normal
	vec3 l = normalize(v_dirtolight_cs);	// Light Direction
	vec3 e = normalize(v_dirtocamera_cs);	// Camera Direction
	vec3 r = reflect(-l, n);				// Reflect Angle
	
	// Vars -------------------------------------------------------------
	float dp = clamp(dot(n, l), 0.0, 1.0);	// Dot Product
	float fresnel = 1.0-clamp(dot(n, e), 0.0, 1.0);	// Fake Fresnel
	float shine = dot(e, r);	// Specular
	
	dp = pow(dp, DP_EXP);
	dp *= mix(0.9, 1.0, v_color.z);
	shine = pow( sqrt((shine+1.0)*0.5), pow(1.0/(roughness+0.001), 4.0) ) * 1.0 * (1.0-roughness);
	fresnel = pow(fresnel, RIM_EXP)*rim;
	
	float lightvalue = mix(AO, (AO*0.5+0.5) * dp, DPSTRENGTH);
	
	// Colors ----------------------------------------------------------------
	// Use only v_color if bottom left pixel is completely white (no texture given)
	//vec4 diffusecolor = v_color;
	float texX = mix(v_color.x, 0.7, v_color.z);
	vec4 diffusecolor = vec4(texture2D(u_texture, vec2(texX, v_color.y)).rgb, 1.0);
	diffusecolor *= 1.1;
	
	// Output ----------------------------------------------------------------
	vec3 outcolor = diffusecolor.rgb * (lightvalue+1.0) / 2.0;	// Shadow
	vec3 ambient = vec3(0.01, 0.0, 0.05);
	ambient = vec3(0.09, 0.04, 0.1);
	outcolor += ambient * (1.0-lightvalue);	// Ambient
	outcolor += (diffusecolor.rgb + (pow(1.0-roughness, SPE_EXP))) * shine*shine * (1.0-roughness);	// Specular
	outcolor += vec3(0.5) * fresnel;	// Rim
	
	outcolor = mix(outcolor, diffusecolor.rgb, emission+(1.0-v_color.a-(1.0-v_color.a)*emission)); // Emission
	outcolor = mix(outcolor, colorblend.rgb*outcolor.rgb, colorblend.a); // Blend Color
	outcolor = mix(outcolor, colorfill.rgb, colorfill.a); // Fill Color
	
    gl_FragColor = vec4(outcolor, alpha);
}



