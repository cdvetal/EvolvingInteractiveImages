in vec4 gl_FragCoord;

uniform vec2 resolution;
uniform float externalVal;

// Precision-adjusted variations of https://www.shadertoy.com/view/4djSRW
float hash(float p) { p = fract(p * 0.011); p *= p + 7.5; p *= p + p; return fract(p); }
float hash(vec2 p) {vec3 p3 = fract(vec3(p.xyx) * 0.13); p3 += dot(p3, p3.yzx + 3.333); return fract((p3.x + p3.y) * p3.z); }

//noise from https://www.shadertoy.com/view/4dS3Wd
float noise(float x) {
    float i = floor(x);
    float f = fract(x);
    float u = f * f * (3.0 - 2.0 * f);
    return mix(hash(i), hash(i + 1.0), u);
}

float noise(float x, float y) {
    vec2 inVec = vec2(x,y);
    vec2 i = floor(inVec);
    vec2 f = fract(inVec);

	// Four corners in 2D of a tile
	float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    // Simple 2D lerp using smoothstep envelope between the values.
	// return vec3(mix(mix(a, b, smoothstep(0.0, 1.0, f.x)),
	//			mix(c, d, smoothstep(0.0, 1.0, f.x)),
	//			smoothstep(0.0, 1.0, f.y)));

	// Same code, with the clamps in smoothstep and common subexpressions
	// optimized away.
    vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void main() {
    vec2 coord = gl_FragCoord.xy;

    vec2 uv = coord / resolution.y;

    float x = uv.x;
    float y = uv.y;

    float r = (min(externalVal,((cos((noise(y,mod(noise(pow((((y+y)+y)/((mod(sin((externalVal*y)),y)+(y-(externalVal+pow(externalVal,mod(noise((x+(noise((sin(((max(externalVal,sin((externalVal*((x+y)-externalVal))))+y)/mod(mod(externalVal,externalVal),x)))-pow(x,noise(tan(max(externalVal,(y*min(externalVal,noise(externalVal,pow(externalVal,y)))))),x))),(x-pow(max(mod(noise(y,y),externalVal),y),pow(x,x))))/min(min(x,pow(y,tan(externalVal))),(externalVal/(externalVal-max(x,mod(externalVal,noise(cos(externalVal),mod(max(x,externalVal),externalVal))))))))),x),(mod(mod(y,x),pow(mod((max(y,cos(y))+externalVal),x),externalVal))+x))))))/pow(externalVal,mod(x,y)))),externalVal),externalVal),x))+(x-(sin(y)*x))))+x)+x))/(cos(min(y,(pow(externalVal,externalVal)+sin(tan(externalVal)))))/externalVal));
    float g = tan(y);
    float b = (y*x);

    gl_FragColor = vec4(r, g, b, 1.0);
}
