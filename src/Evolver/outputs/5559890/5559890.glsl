in vec4 gl_FragCoord;

uniform vec2 resolution;
uniform sampler2D image;
uniform float externalVal;
uniform int nVariables;
uniform float variables[10];
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
float noi(float x) {
    float i = floor(x);
    float f = fract(x);
    float u = f * f * (3.0 - 2.0 * f);
    return mix(hash(i), hash(i + 1.0), u);
}

float noi(float x, float y) {
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

//audio
float aud(float x, float y){
    float center = x * audioSpectrum.length;
    float radius = (y * audioSpectrum.length) / 2;
    int minIndex = int(max(center - radius, 0));
    int maxIndex = int(min(center + radius, audioSpectrum.length));

    float sum = 0;

    for(int i = minIndex; i < maxIndex; i++){
        sum += audioSpectrum[i];
    }

    return sum/(radius/2); //sum/(radius * 2)
}

//like aud but low sounds - first half of spectrum used
float aul(float x, float y){
    float usedLength = audioSpectrum.length / 2;
    float center = x * usedLength;
    float radius = (y * usedLength) / 2;
    int minIndex = int(max(center - radius, 0));
    int maxIndex = int(min(center + radius, usedLength));

    float sum = 0;

    for(int i = minIndex; i < maxIndex; i++){
        sum += audioSpectrum[i];
    }

    return sum/(radius/2);
}

//like aud but high sounds - second half of spectrum used
float auh(float x, float y){
    float usedLength = audioSpectrum.length / 2;
    float center = x * usedLength + usedLength;
    float radius = (y * usedLength) / 2 + usedLength;
    int minIndex = int(max(center - radius, usedLength));
    int maxIndex = int(min(center + radius, audioSpectrum.length));

    float sum = 0;

    for(int i = minIndex; i < maxIndex; i++){
        sum += audioSpectrum[i];
    }

    return sum/(radius/2);
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

float var(float x){
    int varIndexFloor = int(floor(x * nVariables));
    int varIndexCeil = int(ceil(x * nVariables));

    if(varIndexFloor >= nVariables){
        varIndexFloor = nVariables - 1;
    }
    if(varIndexCeil >= nVariables){
        varIndexCeil = nVariables - 1;
    }

    float ratioValue = x - varIndexFloor;

    float valueFloor = (1 - ratioValue) * variables[varIndexFloor];
    float valueCeil = (ratioValue) * variables[varIndexCeil];
    float value = valueFloor + valueCeil;

    return value;
}

vec3 generateRGB(float x, float y){
    float r = var(pow(min(((y+y)+y),(((((y+x)+(0.69926155+y))/(min(max(aud(min(tan(((bri(pow((y+x),x),0.42091477)/(0.8624121+y))+cos(sin(x)))),y),(x+x)),tan(var(tan(max(((cos(y)/sin(0.7015493))*((y+x)+((x+0.05369979)+(y+y)))),aud((((0.85713977+x)+(0.64742124+x))-(x+(0.5502725+y))),bri(bri(0.16505438,0.41240162),tan((y-y))))))))),((0.09446418+y)+(y+(0.57214737+y))))*(x+(y+0.6042096))))+(0.8848792+(x+x)))*bri((y-(y+x)),((y+y)+y)))),max((y+(0.020602942+0.58246136)),pow(pow(max((y+((0.40248495+y)+(x+y))),aud((((y+0.6392285)-y)+(y+0.12107903)),((y+0.551273)+((0.5427879+x)-(0.36049855+x))))),min(((0.8464889+0.07747221)+(y+x)),((y+(0.8609546+y))*x))),((0.3248384+y)+((x+x)+(y+x)))))));
    float g = var(pow(min(((0.96298224+0.22549331)+y),(((((0.12998897+x)+(y+y))/(min(max(aud(min(tan(((bri(pow((x+x),y),y)/(x+x))+cos(sin(x)))),x),(x+0.055055737)),tan(var(tan(max(((cos(y)/sin(x))*((y+y)+((0.8753119+0.3189928)+(x+y)))),aud((((0.20450538+0.9707136)+(0.31122977+x))-(y+(x+0.5360992))),bri(bri(0.4628148,0.9013066),tan((x-x))))))))),((0.38957405+0.9937214)+(y+(x+y))))*(y+(x+x))))+(y+(y+0.80596054)))*bri((x-(0.98221546+y)),((x+x)+0.4278531)))),max((x+(y+0.4221477)),pow(pow(max((0.8305682+((0.8329489+0.84545106)+(x+x))),aud((((x+x)-x)+(0.15441692+0.9357292)),((y+x)+((y+0.21780968)-(0.97659695+0.7489464))))),min(((x+x)+(0.77733403+y)),((0.3537696+(x+0.1739366))*y))),((y+0.8856434)+((x+0.06706363)+(0.076578856+0.96935767)))))));
    float b = var(pow(min(((x+0.6754267)+0.056518435),(((((0.90361565+x)+(0.5293883+y))/(min(max(aud(min(tan(((bri(pow((0.4580058+x),0.7759879),y)/(y+y))+cos(sin(y)))),y),(x+y)),tan(var(tan(max(((cos(y)/sin(x))*((x+y)+((0.6934113+y)+(y+0.5464409)))),aud((((0.042456865+0.7974125)+(x+0.2675743))-(y+(0.74587476+0.98690915))),bri(bri(y,y),tan((y-y))))))))),((0.52530867+0.48409045)+(y+(x+y))))*(y+(0.5358798+x))))+(x+(x+x)))*bri((0.26052028-(y+y)),((y+y)+y)))),max((0.179281+(y+y)),pow(pow(max((x+((0.63582927+x)+(0.31087518+x))),aud((((x+x)-x)+(y+y)),((0.1191954+y)+((x+y)-(y+x))))),min(((x+x)+(x+0.6754251)),((y+(0.9929563+x))*x))),((x+y)+((y+0.80617136)+(x+x)))))));
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
