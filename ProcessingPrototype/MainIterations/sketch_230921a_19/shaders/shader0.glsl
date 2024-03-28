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
    float r = audio(((((y/pow((pow(pow(x,0.54516196),mod(y,0.776386))/y),x))/mod((pow((y/pow(externalVal,0.8040428)),mod(pow(0.72208405,0.9006376),y))/(0.20079279/0.45118713)),externalVal))/(mod(audio(mod(((y/0.85225606)/y),y),pow((y/mod(y,x)),0.95962214)),audio(audio(audio(mod(externalVal,x),(y/externalVal)),externalVal),y))/pow(audio(audio(mod((0.12542963/externalVal),externalVal),pow(0.86147046,x)),0.1872015),x)))/audio(x,mod(pow((0.29179907/0.5488415),externalVal),audio(audio(mod(pow(x,externalVal),((y/y)/(x/x))),externalVal),(0.64059114/pow(mod((externalVal/externalVal),y),y)))))),y);
    float g = audio(((((externalVal/pow((pow(pow(externalVal,0.8826153),mod(x,externalVal))/x),y))/mod((pow((externalVal/pow(0.10080099,x)),mod(pow(x,x),y))/(externalVal/externalVal)),externalVal))/(mod(audio(mod(((externalVal/externalVal)/y),x),pow((externalVal/mod(0.2857306,x)),x)),audio(audio(audio(mod(0.2549386,y),(y/x)),y),y))/pow(audio(audio(mod((0.61610436/externalVal),x),pow(0.5394192,y)),y),0.81536674)))/audio(x,mod(pow((y/0.94587755),externalVal),audio(audio(mod(pow(0.42448425,0.9759438),((y/x)/(x/y))),0.19205332),(y/pow(mod((0.10895133/x),x),x)))))),externalVal);
    float b = audio(((((externalVal/pow((pow(pow(0.96919537,y),mod(externalVal,0.6839552))/0.34094667),x))/mod((pow((0.8860526/pow(externalVal,y)),mod(pow(0.65201354,0.5696671),0.0627563))/(y/externalVal)),x))/(mod(audio(mod(((x/0.48107743)/0.29434562),0.7173028),pow((y/mod(0.29447746,y)),y)),audio(audio(audio(mod(0.25448823,externalVal),(externalVal/x)),externalVal),y))/pow(audio(audio(mod((externalVal/x),externalVal),pow(y,y)),x),y)))/audio(x,mod(pow((y/x),0.6243253),audio(audio(mod(pow(externalVal,0.65033937),((y/0.7855387)/(externalVal/0.2895515))),x),(0.78187346/pow(mod((x/0.608521),externalVal),0.98336005)))))),x);
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
