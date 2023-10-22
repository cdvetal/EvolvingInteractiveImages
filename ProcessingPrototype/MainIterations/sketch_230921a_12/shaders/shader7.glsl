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

    float r = min((pow((sin(cos(externalVal))+y),externalVal)+x),cos(((cos(externalVal)-externalVal)-(mod(tan(min(x,externalVal)),pow(min(x,externalVal),tan(max(x,noise(x,(mod(x,((y/(externalVal/x))*y))/min(x,pow(cos((x-mod(y,cos(y)))),externalVal))))))))/pow((y-sin(externalVal)),x)))));
    float g = ((cos(pow(externalVal,x))+x)+mod(((max(max((y-mod(y,x)),y),tan(sin(y)))*x)-externalVal),(y/externalVal)));
    float b = tan(noise(cos(((externalVal+noise(max(externalVal,pow(cos(y),x)),x))-tan(y))),min(cos(sin((y/y))),externalVal)));

    gl_FragColor = vec4(r, g, b, 1.0);
}
