/*
	Renders vbs with basic shading.
*/

// Constants
const float DP_EXP = 1.0;	// Higher values smooth(?), Lower values sharpen
const float SPE_EXP = 64.0;	// Higher values sharpen, Lower values smooth
const float RIM_EXP = 4.0;	// Higher values sharpen, Lower values smooth
const float EULERNUMBER = 2.71828;	// Funny E number used in logarithmic stuff

// Passed from Vertex Shader
varying vec2 v_uv;
varying vec4 v_color;

varying vec3 v_dirtolight_cs;
varying vec3 v_dirtocamera_cs;
varying vec3 v_normal_cs;

// Uniforms passed in before draw call
//uniform vec4 u_drawmatrix[4]; // [alpha emission roughness rim colorblend[4] colorfill[4]]

uniform sampler2D u_texture;
uniform bool u_usestandard;

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
}

void Palette()
{
	// Varyings -------------------------------------------------------
	// There's some error when normalizing in vertex shader. Looks smoother here
	vec3 n = normalize(v_normal_cs);		// Vertex Normal
	vec3 l = normalize(v_dirtolight_cs);	// Light Direction
	vec3 e = normalize(v_dirtocamera_cs);	// Camera Direction
	vec3 r = reflect(-l, n);				// Reflect Angle
	
	float COLORINDEX = v_uv.y;
	float AO = v_uv.x;
	float DPSTRENGTH = v_color.r;
	float DPMIN = v_color.g;
	float DPMAX = v_color.b;
	
	//dp -= 0.01;
	//dp = 1.0/(1.0 + pow(dp/(1.0-dp), -0.77) );
	float shine = dot(e, r);	// Specular
	float roughness = 0.2;
	//shine = pow( sqrt((shine+1.0)*0.5), pow(1.0/(roughness+0.001), 4.0) ) * 1.0 * (1.0-roughness);
	//shine = shine > roughness*roughness? (1.0-roughness): shine;
	
	float dp = clamp(dot(n, l), 0.0, 1.0);	// Dot Product
	//dp = clamp(dp * (1.0-shine) + shine, 0.0, 1.0);
	
	float lightvalue = mix(
		v_uv.x,
		AO * clamp(dp, DPMIN, DPMAX),
		DPSTRENGTH
	);
	
	vec2 uv = vec2(lightvalue, COLORINDEX);
	vec4 texcolor = texture2D(u_texture, uv);
	vec4 outcolor = vec4(texcolor.rgb, 1.0);
	vec3 ambient = vec3(0.8, 0.7, 1.0);
	
	// Specular
	float speamt = pow(texcolor.a, 4.0);
	
	outcolor += outcolor * (float(shine > (1.0-speamt))) * (1.0-speamt) * (1.74-length(outcolor.rgb)) * AO * 0.5;
	
	//outcolor = mix(outcolor, texture2D(u_texture, vec2(1.0, uv.y)) + vec4(0.2), AO * shine);
	
	outcolor.rgb = mix(outcolor.rgb*ambient, outcolor.rgb, 
		clamp(pow(length(outcolor.rgb), 1.0), 0.0, 1.0)
		);
	
    gl_FragColor = outcolor;
    //gl_FragColor = v_color;
}

void Standard()
{
	// Uniforms -------------------------------------------------------
	float alpha = 1.0;
	float emission = 0.0;
	float roughness = 0.4;
	float rim = 1.0;
	vec4 colorblend = vec4(1.0, 1.0, 1.0, 0.0);
	vec4 colorfill = vec4(1.0, 1.0, 1.0, 0.0);
	
	float COLORINDEX = v_uv.y;
	float AO = v_uv.x;
	float DPSTRENGTH = v_color.r;
	float DPMIN = v_color.g;
	float DPMAX = v_color.b;
	
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
	dp *= mix(0.9, 1.0, v_uv.x);
	shine = pow( sqrt((shine+1.0)*0.5), pow(1.0/(roughness+0.001), 4.0) ) * 1.0 * (1.0-roughness);
	fresnel = pow(fresnel, RIM_EXP)*rim;
	
	// Colors ----------------------------------------------------------------
	// Use only v_color if bottom left pixel is completely white (no texture given)
	//vec4 diffusecolor = v_color;
	float texX = mix(v_uv.x, 0.7, v_color.r);
	vec4 diffusecolor = vec4(texture2D(u_texture, vec2(texX, v_uv[1])).rgb, 1.0);
	diffusecolor *= 1.1;
	
	// Output ----------------------------------------------------------------
	vec3 outcolor = diffusecolor.rgb * (dp+1.0) / 2.0;	// Shadow
	vec3 ambient = vec3(0.01, 0.0, 0.05);
	ambient = vec3(0.09, 0.04, 0.1);
	outcolor += ambient * (1.0-dp);	// Ambient
	outcolor += (diffusecolor.rgb + (pow(1.0-roughness, SPE_EXP))) * shine*shine * (1.0-roughness);	// Specular
	outcolor += vec3(0.5) * fresnel;	// Rim
	
	outcolor = mix(outcolor, diffusecolor.rgb, emission+(1.0-v_color.a-(1.0-v_color.a)*emission)); // Emission
	outcolor = mix(outcolor, colorblend.rgb*outcolor.rgb, colorblend.a); // Blend Color
	outcolor = mix(outcolor, colorfill.rgb, colorfill.a); // Fill Color
	
    gl_FragColor = vec4(outcolor, alpha);
}

