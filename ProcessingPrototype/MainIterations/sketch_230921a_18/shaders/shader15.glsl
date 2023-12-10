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
    float r = bri(audio(y,bri(mod(audio(bri(mod(bri(audio(bri(bri(y,externalVal),bri(externalVal,audio(mod(bri(audio(mod(externalVal,x),mod(y,y)),externalVal),audio(bri(y,y),mod(bri(y,x),x))),externalVal))),mod(y,externalVal)),x),x),externalVal),mod(audio(bri(mod(y,bri(x,y)),externalVal),bri(bri(audio(y,mod(y,externalVal)),bri(y,audio(x,mod(y,y)))),bri(y,audio(x,mod(y,y))))),x)),mod(externalVal,y)),externalVal)),externalVal);
    float g = audio(bri(y,audio(x,mod(x,mod(audio(bri(audio(audio(x,audio(y,y)),externalVal),bri(bri(externalVal,audio(bri(audio(externalVal,x),y),externalVal)),mod(x,audio(audio(mod(audio(externalVal,audio(bri(bri(y,audio(audio(externalVal,mod(audio(bri(externalVal,audio(y,audio(bri(externalVal,x),mod(mod(y,externalVal),audio(x,externalVal))))),mod(externalVal,bri(mod(mod(x,externalVal),y),x))),y)),bri(externalVal,audio(audio(y,mod(x,y)),y)))),externalVal),externalVal)),y),mod(externalVal,audio(mod(externalVal,x),externalVal))),x)))),mod(y,y)),audio(audio(mod(x,audio(externalVal,mod(mod(mod(externalVal,bri(mod(externalVal,y),mod(x,mod(y,externalVal)))),bri(x,audio(x,audio(x,mod(externalVal,y))))),mod(mod(externalVal,bri(x,mod(externalVal,externalVal))),bri(mod(y,bri(audio(externalVal,x),mod(x,externalVal))),bri(x,mod(y,x))))))),mod(bri(mod(audio(audio(externalVal,x),externalVal),mod(x,mod(audio(x,mod(bri(audio(y,externalVal),externalVal),audio(mod(y,mod(y,bri(bri(bri(bri(bri(audio(y,y),mod(externalVal,bri(audio(mod(externalVal,bri(bri(mod(y,bri(y,y)),bri(externalVal,bri(x,y))),bri(mod(x,audio(externalVal,x)),externalVal))),y),mod(bri(bri(y,mod(x,mod(x,externalVal))),y),externalVal)))),audio(bri(x,audio(bri(bri(x,mod(y,bri(x,y))),audio(mod(x,x),mod(mod(mod(x,y),externalVal),audio(externalVal,y)))),x)),mod(y,externalVal))),mod(mod(mod(mod(y,y),audio(externalVal,x)),mod(mod(bri(audio(y,bri(bri(externalVal,audio(x,mod(externalVal,externalVal))),externalVal)),audio(mod(audio(audio(x,x),externalVal),audio(audio(bri(externalVal,x),audio(x,externalVal)),audio(x,mod(audio(audio(x,externalVal),externalVal),bri(audio(y,mod(y,bri(bri(bri(bri(bri(audio(x,y),mod(y,audio(bri(mod(externalVal,bri(bri(mod(y,bri(y,y)),bri(externalVal,bri(x,y))),bri(mod(externalVal,x),externalVal))),externalVal),mod(bri(bri(externalVal,mod(x,audio(x,y))),x),y)))),audio(bri(y,audio(bri(bri(x,bri(externalVal,mod(bri(y,mod(mod(audio(x,x),externalVal),x)),x))),audio(y,bri(bri(externalVal,audio(y,mod(y,y))),externalVal))),x)),mod(x,externalVal))),mod(audio(mod(mod(y,externalVal),audio(externalVal,x)),mod(mod(bri(audio(y,bri(audio(externalVal,audio(x,mod(y,externalVal))),externalVal)),audio(mod(audio(audio(x,x),externalVal),bri(audio(bri(externalVal,x),audio(x,externalVal)),audio(externalVal,bri(externalVal,y)))),y)),y),audio(mod(bri(bri(y,mod(mod(mod(externalVal,externalVal),y),audio(externalVal,y))),externalVal),externalVal),mod(x,externalVal)))),audio(mod(audio(bri(mod(audio(x,x),audio(y,audio(x,y))),audio(x,bri(bri(externalVal,bri(x,x)),y))),x),x),mod(mod(y,bri(externalVal,mod(bri(externalVal,audio(audio(bri(x,y),externalVal),x)),x))),externalVal)))),mod(x,mod(bri(mod(externalVal,y),y),mod(x,mod(x,bri(audio(y,mod(y,y)),x)))))),audio(x,mod(bri(y,y),mod(x,externalVal)))))),bri(externalVal,x)))))),y)),externalVal),mod(mod(bri(bri(y,audio(mod(mod(externalVal,y),y),audio(externalVal,y))),externalVal),externalVal),mod(x,y)))),audio(mod(audio(bri(mod(audio(y,x),audio(x,mod(y,x))),audio(x,bri(audio(externalVal,bri(y,x)),y))),y),x),mod(mod(y,bri(externalVal,mod(bri(y,audio(mod(audio(x,y),externalVal),x)),x))),externalVal)))),mod(x,audio(bri(audio(externalVal,x),externalVal),mod(x,mod(y,bri(bri(y,audio(x,y)),x)))))),audio(x,mod(bri(y,y),audio(x,y)))))),audio(y,x)))),bri(audio(bri(x,x),x),y)))),y),y)),y))))),y);
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
