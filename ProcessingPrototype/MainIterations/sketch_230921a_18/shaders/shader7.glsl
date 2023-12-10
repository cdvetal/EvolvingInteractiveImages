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
    float r = audio(audio(externalVal,bri(audio(externalVal,mod(y,externalVal)),externalVal)),externalVal);
    float g = audio(bri(y,audio(x,mod(x,mod(mod(bri(x,mod(y,y)),mod(y,y)),mod(audio(mod(x,audio(externalVal,audio(mod(mod(externalVal,bri(mod(externalVal,x),mod(x,mod(externalVal,y)))),bri(x,bri(x,audio(x,mod(externalVal,y))))),mod(mod(externalVal,bri(x,mod(externalVal,externalVal))),bri(mod(externalVal,bri(audio(externalVal,x),audio(x,externalVal))),bri(x,mod(y,y))))))),mod(audio(mod(audio(audio(y,x),externalVal),mod(y,mod(audio(x,mod(bri(audio(x,externalVal),externalVal),bri(mod(y,mod(y,bri(bri(bri(bri(audio(mod(y,y),mod(externalVal,bri(bri(mod(externalVal,bri(bri(audio(y,bri(y,x)),mod(mod(externalVal,bri(bri(audio(y,bri(y,y)),bri(externalVal,mod(mod(x,y),externalVal))),bri(y,x))),externalVal)),bri(mod(x,mod(externalVal,x)),externalVal))),externalVal),mod(bri(bri(y,mod(x,mod(x,y))),y),externalVal)))),audio(bri(y,audio(bri(bri(x,audio(y,bri(x,y))),audio(mod(x,x),mod(mod(mod(externalVal,y),x),audio(externalVal,y)))),x)),mod(externalVal,externalVal))),mod(mod(mod(mod(y,y),audio(externalVal,x)),mod(mod(bri(bri(externalVal,bri(bri(y,audio(x,mod(y,externalVal))),externalVal)),audio(mod(audio(audio(x,x),externalVal),bri(audio(bri(externalVal,x),audio(x,externalVal)),audio(y,mod(audio(audio(x,externalVal),externalVal),bri(mod(externalVal,mod(y,bri(audio(bri(bri(bri(audio(x,x),mod(y,audio(bri(mod(externalVal,bri(bri(audio(x,bri(y,x)),bri(externalVal,bri(x,y))),bri(mod(externalVal,x),externalVal))),externalVal),mod(bri(bri(y,mod(x,audio(x,x))),y),y)))),audio(audio(y,bri(bri(bri(x,mod(x,bri(x,y))),audio(mod(y,x),mod(y,mod(externalVal,mod(mod(y,x),mod(x,x)))))),x)),mod(x,externalVal))),mod(audio(mod(mod(y,externalVal),audio(externalVal,x)),mod(mod(bri(audio(y,audio(bri(externalVal,audio(x,mod(y,y))),externalVal)),audio(mod(audio(bri(x,x),externalVal),bri(mod(bri(externalVal,x),audio(x,externalVal)),audio(externalVal,bri(externalVal,externalVal)))),y)),externalVal),audio(mod(bri(bri(y,audio(mod(mod(externalVal,y),y),bri(externalVal,y))),externalVal),externalVal),mod(x,y)))),audio(mod(audio(bri(mod(audio(x,x),audio(y,mod(x,x))),audio(x,bri(audio(externalVal,bri(x,x)),y))),y),x),mod(mod(y,bri(externalVal,audio(bri(externalVal,audio(audio(audio(x,y),externalVal),x)),x))),externalVal)))),mod(x,mod(bri(audio(externalVal,y),y),mod(x,mod(y,bri(bri(y,audio(y,externalVal)),x)))))),audio(y,audio(bri(y,y),audio(x,externalVal)))))),audio(externalVal,x)))))),y)),externalVal),mod(mod(bri(bri(y,audio(mod(mod(externalVal,y),y),mod(externalVal,y))),externalVal),externalVal),mod(x,y)))),audio(mod(audio(audio(mod(bri(y,x),audio(x,mod(x,y))),audio(x,bri(audio(y,bri(y,x)),y))),y),x),mod(mod(y,bri(externalVal,mod(bri(y,audio(mod(audio(x,x),externalVal),x)),x))),externalVal)))),mod(x,mod(bri(audio(externalVal,y),externalVal),mod(x,mod(y,bri(bri(y,audio(x,y)),x)))))),mod(x,audio(bri(y,y),audio(x,y)))))),audio(y,x)))),audio(mod(bri(x,x),x),y)))),externalVal),y)),y))))),y);
    float b = bri(y,x);
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
