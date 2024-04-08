in vec4 gl_FragCoord;

uniform vec2 resolution;
uniform sampler2D image;
uniform float externalVal;
uniform float audioSpectrum[512];

const float EPSILON = 1e-10;

//conversions from https://www.shadertoy.com/view/4dKcWK
vec3 RGBtoHCV(vec3 rgb)
{
    vec4 p = (rgb.g < rgb.b) ? vec4(rgb.bg, -1., 2. / 3.) : vec4(rgb.gb, 0., -1. / 3.);
    vec4 q = (rgb.r < p.x) ? vec4(p.xyw, rgb.r) : vec4(rgb.r, p.yzx);
    float c = q.x - min(q.w, q.y);
    float h = abs((q.w - q.y) / (6. * c + EPSILON) + q.z);
    return vec3(h, c, q.x);
}

vec3 RGBtoHSV(vec3 rgb)
{
    // RGB [0..1] to Hue-Saturation-Value [0..1]
    vec3 hcv = RGBtoHCV(rgb);
    float s = hcv.y / (hcv.z + EPSILON);
    return vec3(hcv.x, s, hcv.z);
}

vec3 HUEtoRGB(float hue)
{
    vec3 rgb = abs(hue * 6. - vec3(3, 2, 4)) * vec3(1, -1, -1) + vec3(-1, 2, 2);
    return clamp(rgb, 0., 1.);
}

vec3 HSVtoRGB(vec3 hsv)
{
    // Hue-Saturation-Value [0..1] to RGB [0..1]
    vec3 rgb = HUEtoRGB(hsv.x);
    return ((rgb - 1.) * hsv.y + 1.) * hsv.z;
}


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

	float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float audio(float x, float y){
    float center = x * audioSpectrum.length;
    float radius = (y * audioSpectrum.length) / 2;
    int minIndex = int(max(center - radius, 0));
    int maxIndex = int(min(center + radius, audioSpectrum.length));

    float sum = 0;

    for(int i = minIndex; i < maxIndex; i++){
        sum += audioSpectrum[i];
    }

    return sum/(radius * 2);
}

float bri(float x, float y){ //brightness https://stackoverflow.com/questions/596216/formula-to-determine-perceived-brightness-of-rgb-color
    float xFloor = floor(x);
    float yFloor = floor(y);

    float xRemainder = x - xFloor;
    float yRemainder = y - yFloor;

    if (int(xFloor) % 2 != 0) x = 1 - xRemainder; 
    if (int(yFloor) % 2 != 0) y = 1 - yRemainder; 
    
    vec2 uv = vec2(x,y);
    vec3 rgb = texture(image, uv).rgb;

    float brightness = (0.2126*rgb.r + 0.7152*rgb.g + 0.0722*rgb.b);
    return brightness;
}

vec3 generateRGB(float x, float y){
    float r = audio(x,bri(audio(audio(y,x),x),y));
    float g = audio(audio(pow(externalVal,pow(x,pow(externalVal,bri(pow(bri(audio(bri(y,pow(audio(audio(x,audio(pow(pow(externalVal,pow(externalVal,x)),pow(audio(externalVal,externalVal),pow(audio(x,y),bri(externalVal,pow(bri(externalVal,y),x))))),pow(pow(audio(audio(externalVal,pow(bri(pow(audio(audio(y,bri(y,x)),bri(audio(x,y),pow(x,pow(audio(bri(externalVal,bri(y,y)),bri(audio(y,pow(x,audio(externalVal,externalVal))),bri(externalVal,audio(externalVal,audio(y,y))))),x)))),y),pow(audio(y,x),bri(bri(y,y),y))),externalVal)),audio(externalVal,bri(y,bri(y,pow(pow(x,pow(audio(pow(externalVal,audio(audio(externalVal,x),x)),y),externalVal)),audio(pow(x,y),audio(bri(bri(audio(pow(y,audio(y,y)),x),pow(y,pow(pow(audio(x,bri(x,externalVal)),y),audio(audio(pow(x,x),y),x)))),pow(audio(bri(pow(y,externalVal),y),x),externalVal)),externalVal))))))),x),audio(x,externalVal)))),audio(bri(y,audio(bri(pow(externalVal,externalVal),bri(pow(externalVal,pow(audio(y,pow(x,pow(y,x))),y)),externalVal)),pow(bri(y,y),y))),pow(pow(pow(externalVal,x),y),y))),pow(x,y))),audio(audio(externalVal,externalVal),pow(x,pow(externalVal,externalVal)))),audio(y,pow(pow(y,pow(pow(x,x),audio(bri(y,externalVal),x))),pow(x,audio(bri(audio(audio(pow(externalVal,audio(externalVal,y)),pow(y,externalVal)),y),externalVal),y))))),bri(x,bri(pow(externalVal,pow(x,audio(audio(x,pow(externalVal,audio(externalVal,audio(x,x)))),audio(externalVal,audio(bri(y,externalVal),audio(pow(bri(pow(audio(pow(audio(y,externalVal),audio(bri(audio(pow(x,bri(pow(audio(y,bri(y,x)),audio(x,audio(audio(x,externalVal),x))),externalVal)),y),bri(pow(x,pow(y,externalVal)),externalVal)),audio(pow(externalVal,x),pow(bri(bri(pow(audio(x,audio(audio(externalVal,y),audio(bri(externalVal,x),audio(externalVal,x)))),audio(audio(externalVal,y),audio(pow(audio(x,x),pow(externalVal,x)),externalVal))),pow(audio(externalVal,x),pow(externalVal,x))),x),x)))),externalVal),y),bri(externalVal,bri(audio(audio(y,y),x),pow(externalVal,bri(pow(externalVal,audio(audio(audio(y,x),pow(bri(pow(audio(bri(bri(x,externalVal),bri(externalVal,y)),x),bri(externalVal,audio(bri(y,externalVal),x))),externalVal),externalVal)),externalVal)),y))))),pow(externalVal,x)),x)))))),x))),externalVal)))),externalVal),audio(bri(bri(x,pow(audio(y,audio(x,bri(y,x))),audio(audio(audio(y,x),pow(audio(externalVal,externalVal),audio(x,y))),bri(audio(externalVal,x),bri(externalVal,pow(pow(audio(y,pow(pow(externalVal,y),externalVal)),bri(bri(audio(audio(audio(x,pow(bri(audio(externalVal,externalVal),x),audio(audio(pow(audio(x,pow(y,x)),audio(audio(externalVal,x),pow(audio(pow(y,y),bri(externalVal,externalVal)),pow(y,pow(y,externalVal))))),bri(x,x)),externalVal))),externalVal),externalVal),bri(bri(bri(x,x),externalVal),externalVal)),y)),y)))))),externalVal),y));
    float b = pow(audio(y,x),x);
    return vec3(r,g,b);
}

void main() {
    vec2 coord = gl_FragCoord.xy;
    
    vec2 uv = coord / resolution.y;

    float x = uv.x;
    float y = uv.y;

    vec3 RGB = generateRGB(x, y);

    gl_FragColor = vec4(RGB.x, RGB.y, RGB.z, 1.0);
}
