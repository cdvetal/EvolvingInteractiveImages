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
    float r = audio(audio(y,audio(y,mod(bri(x,externalVal),audio(audio(bri(mod(audio(bri(mod(audio(audio(bri(audio(externalVal,externalVal),bri(y,bri(mod(mod(externalVal,audio(mod(y,audio(externalVal,audio(audio(mod(mod(x,mod(y,externalVal)),bri(y,audio(y,mod(audio(bri(mod(y,bri(y,y)),externalVal),audio(audio(y,audio(bri(externalVal,x),mod(externalVal,y))),bri(y,audio(x,audio(y,y))))),y)))),bri(bri(externalVal,y),x)),externalVal))),bri(x,audio(x,externalVal)))),audio(audio(y,y),mod(bri(y,y),x))),externalVal))),mod(y,externalVal)),x),y),externalVal),bri(bri(audio(y,bri(y,externalVal)),externalVal),y)),mod(externalVal,y)),externalVal),y),x)))),externalVal);
    float g = audio(bri(y,audio(x,audio(y,mod(audio(bri(audio(mod(mod(externalVal,y),x),audio(externalVal,y)),bri(bri(externalVal,audio(bri(audio(externalVal,x),y),externalVal)),audio(x,audio(audio(mod(bri(y,audio(bri(bri(y,bri(bri(externalVal,mod(audio(bri(externalVal,mod(y,audio(bri(externalVal,y),mod(mod(externalVal,externalVal),audio(x,externalVal))))),mod(externalVal,bri(mod(mod(x,y),externalVal),x))),y)),bri(externalVal,audio(mod(y,mod(x,y)),y)))),externalVal),externalVal)),x),mod(externalVal,bri(audio(externalVal,x),externalVal))),x)))),mod(externalVal,y)),audio(audio(mod(x,audio(externalVal,mod(mod(mod(externalVal,bri(mod(externalVal,x),audio(externalVal,mod(externalVal,externalVal)))),bri(x,audio(x,bri(externalVal,audio(bri(audio(x,audio(bri(externalVal,mod(audio(bri(externalVal,audio(y,audio(bri(externalVal,x),bri(y,x)))),mod(externalVal,bri(mod(mod(x,y),y),x))),y)),bri(externalVal,audio(mod(y,mod(x,y)),y)))),y),externalVal))))),mod(mod(externalVal,bri(x,mod(externalVal,externalVal))),bri(mod(externalVal,bri(audio(externalVal,y),audio(y,externalVal))),bri(x,mod(externalVal,y))))))),mod(audio(mod(audio(audio(y,x),externalVal),mod(y,mod(audio(x,mod(audio(audio(x,externalVal),externalVal),bri(mod(externalVal,audio(y,bri(bri(bri(bri(bri(mod(y,y),mod(y,bri(bri(mod(y,bri(bri(mod(y,bri(y,y)),bri(externalVal,bri(x,y))),bri(mod(x,audio(y,y)),y))),externalVal),mod(bri(audio(y,mod(x,mod(x,y))),x),y)))),audio(bri(y,bri(bri(bri(y,mod(y,bri(x,externalVal))),audio(mod(y,x),mod(x,mod(externalVal,audio(audio(y,x),mod(x,x)))))),y)),mod(y,externalVal))),mod(mod(mod(mod(y,externalVal),audio(externalVal,x)),mod(mod(bri(audio(y,bri(bri(externalVal,audio(x,mod(externalVal,y))),externalVal)),audio(mod(audio(audio(x,x),externalVal),bri(audio(audio(y,x),audio(x,externalVal)),audio(x,mod(audio(audio(x,externalVal),externalVal),audio(mod(y,mod(y,mod(x,y))),bri(externalVal,x)))))),y)),externalVal),mod(mod(bri(bri(x,mod(mod(mod(externalVal,x),x),audio(externalVal,externalVal))),externalVal),externalVal),mod(x,y)))),audio(mod(audio(audio(mod(audio(y,x),audio(x,mod(x,y))),audio(x,bri(bri(y,bri(y,x)),externalVal))),y),x),mod(mod(y,bri(externalVal,mod(bri(y,mod(audio(audio(x,y),externalVal),x)),x))),externalVal)))),mod(x,mod(bri(mod(externalVal,x),y),mod(x,mod(y,bri(audio(y,audio(y,x)),x)))))),mod(x,audio(audio(y,y),audio(x,y)))))),bri(externalVal,y)))),bri(bri(y,audio(audio(audio(y,y),externalVal),x)),x)))),externalVal),y)),y))))),y);
    float b = bri(x,x);
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
