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

    float r = (y*y);
    float g = tan(cos((pow((x-((noise(y,pow(noise(x,y),x))-(cos(x)+min(pow((y+min(y,externalVal)),x),externalVal)))/externalVal)),min(mod(externalVal,tan(sin(sin(((cos(mod(((cos(mod(externalVal,y))*(x-max(max((noise(externalVal,mod(max((y*x),(externalVal/sin(y))),x))*externalVal),(y+(x-x))),(mod((min(x,y)*((y*((externalVal+min(x,cos(pow(x,cos(y)))))*max(pow(pow(sin(cos(max((y*y),externalVal))),y),y),(y+x))))-x)),externalVal)-y))))/externalVal),externalVal))/externalVal)*(sin((y/(y+tan((sin(x)/tan((externalVal/externalVal)))))))/(mod(externalVal,y)/tan(y)))))))),x))*((sin(externalVal)*(mod(externalVal,x)/min(y,sin(externalVal))))-cos(tan(externalVal))))));
    float b = (sin(externalVal)*externalVal);

    gl_FragColor = vec4(r, g, b, 1.0);
}
