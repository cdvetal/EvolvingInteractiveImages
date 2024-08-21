/* ############################
Evolved using software @ https://github.com/cdvetal/EvolvingInteractiveImages





############################ */

in vec4 gl_FragCoord;

in vec2 uv;
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
    int varIndex = int(round(x * nVariables));

    if(varIndex >= nVariables){
        varIndex = nVariables - 1;
    }

    return variables[varIndex];
}

float add(float a, float b){
    return a + b;
}

float sub(float a, float b){
    return a - b;
}

float mul(float a, float b){
    return a * b;
}

float div(float a, float b){
    return a / b;
}

vec3 generateRGB(float x, float y){
    float r = sin(min(x,add(0.6815276,min(div(min(0.8305011,mul(mul(y,mul(pow(div(bri(y,bri(sub(sin(tan(cos(x))),add(x,aud(bri(pow(y,y),min(y,x)),sub(bri(0.48882008,0.33282423),cos(x))))),bri(div(aud(x,sin(0.09663129)),y),add(sub(pow(min(x,y),add(x,y)),0.5877123),aud(bri(sub(x,y),max(x,y)),bri(add(x,x),0.6641512)))))),bri(0.3792286,bri(div(pow(sub(aud(0.89410996,min(y,x)),max(add(0.68576694,0.16294146),bri(y,x))),tan(cos(add(0.9429543,y)))),min(sub(sin(0.99481535),pow(div(0.9122758,y),max(x,y))),0.42757964)),y))),x),y)),tan(x))),tan(max(sin(y),y))),aud(sub(bri(y,cos(y)),aud(y,x)),y)))));
    float g = sin(min(x,add(0.16226411,min(div(min(x,mul(mul(x,mul(pow(div(bri(0.31272745,bri(sub(sin(tan(cos(y))),add(0.9270539,aud(bri(pow(x,x),min(y,0.80687666)),sub(bri(x,0.6646404),cos(y))))),bri(div(aud(y,sin(x)),0.19025564),add(sub(pow(min(0.27398157,0.7119241),add(x,0.5418911)),x),aud(bri(sub(y,0.055538654),max(0.37244654,y)),bri(add(0.3835647,y),0.36642575)))))),bri(0.5408783,bri(div(pow(sub(aud(y,min(y,x)),max(add(0.48301196,0.597245),bri(y,0.45125508))),tan(cos(add(x,x)))),min(sub(sin(0.17424393),pow(div(0.26508594,y),max(x,0.90705967))),y)),0.3399334))),0.88281417),0.3595667)),tan(y))),tan(max(sin(0.9250424),x))),aud(sub(bri(y,cos(x)),aud(x,y)),x)))));
    float b = sin(min(x,add(0.9042325,min(div(min(y,mul(mul(0.22452188,mul(pow(div(bri(0.865916,bri(sub(sin(tan(cos(x))),add(y,aud(bri(pow(0.8824494,x),min(0.29583287,y)),sub(bri(0.18559718,x),cos(0.7808871))))),bri(div(aud(y,sin(y)),y),add(sub(pow(min(0.61621714,y),add(x,0.6601784)),0.48460627),aud(bri(sub(y,0.06615257),max(0.22638059,x)),bri(add(0.7378967,y),0.04335308)))))),bri(y,bri(div(pow(sub(aud(y,min(y,0.50171375)),max(add(y,y),bri(x,y))),tan(cos(add(x,x)))),min(sub(sin(x),pow(div(x,y),max(y,y))),x)),y))),y),0.6916058)),tan(0.83264303))),tan(max(sin(0.15694308),y))),aud(sub(bri(0.1903758,cos(x)),aud(0.26256895,y)),x)))));
    return vec3(r,g,b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);

    gl_FragColor = vec4(RGB.x, RGB.y, RGB.z, 1.0);
}
