/* ############################
Evolved using software @ https://github.com/cdvetal/EvolvingInteractiveImages

// 2024 - 7 - 25

// Generation: 5
// Population Size: 18; Elite Size: 1; Mutation Rate: 0.4; Crossover Rate: 0.3; Tournament Size: 3
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
    float r = add(y,aud(cos(aud(mul(pow(cos(y),y),x),div(sin(tan(cos(min(x,div(cos(0.9711797),pow(y,pow(x,min(0.9654591,y)))))))),pow(sub(add(min(0.6663513,cos(tan(y))),x),add(aul(add(aud(sub(sub(x,mul(y,0.50396395)),mul(y,add(cos(x),aud(x,x)))),y),x),div(0.1709845,0.7190933)),pow(y,max(cos(cos(cos(x))),y)))),0.119140625)))),sub(auh(0.48338938,y),add(sub(var(sin(sub(x,y))),0.12968731),max(aud(aul(y,x),auh(var(auh(x,cos(aul(min(max(x,aud(aud(y,0.6811824),aul(y,y))),add(min(x,y),mul(sub(y,0.81571674),sin(x)))),sub(y,y))))),x)),pow(aud(y,0.85561013),tan(0.68790007)))))));
    float g = add(y,aud(cos(aud(mul(pow(cos(y),0.7618742),0.45095325),div(sin(tan(cos(min(y,div(cos(0.97989154),pow(y,pow(y,min(y,x)))))))),pow(sub(add(min(x,cos(tan(y))),0.59772825),add(aul(add(aud(sub(sub(x,mul(x,0.7706981)),mul(y,add(cos(0.811748),aud(0.2975304,y)))),0.6203754),0.8474183),div(x,x)),pow(y,max(cos(cos(cos(0.80651236))),x)))),y)))),sub(auh(x,x),add(sub(var(sin(sub(x,x))),y),max(aud(aul(x,0.10228753),auh(var(auh(x,cos(aul(min(max(x,aud(aud(0.07221103,x),aul(y,y))),add(min(y,y),mul(sub(x,y),sin(y)))),sub(0.9126463,x))))),0.63980913)),pow(aud(x,x),tan(0.16162777)))))));
    float b = add(0.15658426,aud(cos(aud(mul(pow(cos(0.92779803),y),y),div(sin(tan(cos(min(0.5521176,div(cos(y),pow(0.6049266,pow(0.50286627,min(x,0.82717896)))))))),pow(sub(add(min(y,cos(tan(x))),x),add(aul(add(aud(sub(sub(0.03392887,mul(y,y)),mul(0.94456863,add(cos(0.5493355),aud(x,y)))),y),x),div(0.6367965,x)),pow(x,max(cos(cos(cos(y))),y)))),y)))),sub(auh(0.69600916,0.47520256),add(sub(var(sin(sub(0.8840163,y))),0.9477477),max(aud(aul(0.7445643,x),auh(var(auh(x,cos(aul(min(max(x,aud(aud(x,0.57265425),aul(x,y))),add(min(x,y),mul(sub(x,y),sin(x)))),sub(y,0.7604599))))),x)),pow(aud(x,x),tan(0.8688388)))))));
    return vec3(r,g,b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);

    gl_FragColor = vec4(RGB.x, RGB.y, RGB.z, 1.0);
}
