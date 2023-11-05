in vec4 gl_FragCoord;

uniform vec2 resolution;
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

vec3 generateRGB(float x, float y){
    float r = pow(y,(x-(max(mod(externalVal,audio(audio(x,min(externalVal,max(x,audio(cos(noise(externalVal,x)),externalVal)))),noise(noise(x,((mod(((noise(noise(mod(y,sin(sin(tan(min((x/(x+externalVal)),tan(externalVal)))))),((cos(x)/sin(audio((audio(y,min(y,cos(max(y,pow(x,y)))))/tan(y)),externalVal)))-(externalVal/audio(x,pow(((externalVal+(audio(y,sin(mod(pow(audio(audio(max(y,pow(externalVal,externalVal)),mod(tan(externalVal),noise(externalVal,x))),externalVal),audio(mod(x,y),pow(mod(audio(y,y),y),tan((x/externalVal))))),y)))-x))*audio(externalVal,(externalVal/y))),externalVal))))),noise(mod(mod(sin(y),noise(y,(min(x,externalVal)+x))),y),(tan(x)/(x+x))))+x)-(x+externalVal)),x)/min((x*max(x,(noise(((externalVal*externalVal)+(pow((x+x),y)*externalVal)),pow(noise(pow(x,noise(y,(audio(externalVal,audio(min(y,x),externalVal))*x))),(externalVal*min(audio(x,x),sin(externalVal)))),noise(y,externalVal)))*audio(x,noise(x,cos(audio(y,y))))))),x))/externalVal)),y))),externalVal)/externalVal)));
    float g = mod(y,sin((audio(mod(audio(pow(externalVal,(externalVal/(externalVal/sin((x/(x/externalVal)))))),audio(noise(pow((noise((y/y),y)+min(externalVal,pow(((sin(max(x,x))-cos(audio(externalVal,audio((x+(min((cos(pow(noise((cos(y)*externalVal),sin(x)),cos(sin(externalVal))))-x),mod(sin(externalVal),max(y,audio((y+externalVal),max(mod(x,min(tan(noise(x,externalVal)),(audio((min(externalVal,y)+x),sin(externalVal))+y))),y)))))*y)),pow((audio(tan((x/audio(x,mod(sin(tan(min(x,max(x,y)))),((sin(x)+mod((externalVal+max(y,externalVal)),externalVal))/x))))),((y*x)-sin(pow(cos(min(x,pow(y,y))),externalVal))))/min(externalVal,(y+(min(x,y)/externalVal)))),min(externalVal,min(y,sin(externalVal))))))))+y),sin(x)))),x),externalVal),y)),audio(x,y)),x)/max(x,mod(externalVal,y)))));
    float b = (((cos(externalVal)-x)+x)*x);
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
