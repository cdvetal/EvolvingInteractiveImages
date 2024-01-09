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
    float r = ((bri(audio(y,((x/(externalVal+x))*((externalVal+externalVal)*y))),y)*y)-y);
    float g = (externalVal+((externalVal*(bri(bri((y*(((x-externalVal)*(externalVal-(x/y)))/externalVal)),(x+y)),externalVal)-y))-x));
    float b = bri((x-((y*((x-x)-(externalVal/((bri(((((bri(externalVal,(externalVal+x))+x)*externalVal)-y)+externalVal),((externalVal/(x/x))+(y/(x/(x-y)))))-x)/((y-(x+audio(bri((audio(((externalVal+externalVal)-audio(audio(x,externalVal),audio(x,y))),(((y/x)-externalVal)/y))/audio(bri(y,(bri(audio(externalVal,x),(bri(bri(bri(y,((x-externalVal)-(((y*externalVal)*x)-(x+y)))),(y-y)),externalVal)+y))-bri((bri(y,(externalVal-audio(y,(bri((bri((bri(((y+x)-x),y)*(x/x)),((((audio(externalVal,x)/(y-x))*(audio(y,y)*(externalVal-externalVal)))*bri(y,((externalVal*x)+y)))-bri(bri(((x+y)-(externalVal/externalVal)),((externalVal-externalVal)/(x*x))),(y*x))))/x),(y*(audio(x,externalVal)/audio(externalVal,bri(y,audio((externalVal-(externalVal-y)),x))))))*((externalVal*y)/x)))))-x),bri(y,(y-x))))),audio((y+audio(audio(((y-externalVal)/((externalVal-((externalVal*bri((x+(x*x)),audio(((externalVal/((bri(externalVal,externalVal)-y)/externalVal))/((externalVal-bri(audio(externalVal,y),externalVal))*(bri(y,(x*x))*(x/(externalVal/x))))),bri((((bri(x,x)/y)+externalVal)+externalVal),(externalVal-((x*externalVal)/bri((y/x),(y-externalVal))))))))/y))-x)),bri(audio(bri(bri(x,bri((y+(externalVal*(y+audio((x*x),externalVal)))),((x*y)/externalVal))),((x/externalVal)*(y-audio(externalVal,bri(x,((x-x)/bri(y,x))))))),x),y)),x)),bri(y,externalVal)))),externalVal),x)))/y)))))-((x+x)+externalVal))),externalVal);
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
