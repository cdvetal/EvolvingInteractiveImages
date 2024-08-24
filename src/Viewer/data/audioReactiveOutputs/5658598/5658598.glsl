/* ############################
Evolved using software @ https://github.com/cdvetal/EvolvingInteractiveImages

// 2024 - 8 - 23

// Generation: 1
// Population Size: 21; Elite Size: 1; Mutation Rate: 0.4813084; Crossover Rate: 0.41121495; Tournament Size: 3
############################ */

precision mediump float;

attribute vec2 a_Position;
attribute vec2 a_TexCoord;

varying vec2 uv;

uniform sampler2D image;
uniform float externalVal;
uniform int nVariables;
uniform float variables[10];
uniform float audioSpectrum[512];
const int audioSpectrumLength = 512;

const float EPSILON = 1e-10;

float hash(float p) {
    p = fract(p * 0.011);
    p *= p + 7.5;
    p *= p + p;
    return fract(p);
}

float hash(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.13);
    p3 += dot(p3, p3.yzx + 3.333);
    return fract((p3.x + p3.y) * p3.z);
}

float noi(float x) {
    float i = floor(x);
    float f = fract(x);
    float u = f * f * (3.0 - 2.0 * f);
    return mix(hash(i), hash(i + 1.0), u);
}

float noi(float x, float y) {
    vec2 inVec = vec2(x, y);
    vec2 i = floor(inVec);
    vec2 f = fract(inVec);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float aud(float x, float y) {
    float center = x * float(audioSpectrumLength);
    float radius = (y * float(audioSpectrumLength)) / 2.0;
    int minIndex = int(max(center - radius, 0.0));
    int maxIndex = int(min(center + radius, float(audioSpectrumLength)));

    float sum = 0.0;

    for (int i = minIndex; i < maxIndex; i++) {
        sum += audioSpectrum[i];
    }

    return sum / (radius / 2.0);
}

float aul(float x, float y) {
    float usedLength = float(audioSpectrumLength) / 2.0;
    float center = x * usedLength;
    float radius = (y * usedLength) / 2.0;
    int minIndex = int(max(center - radius, 0.0));
    int maxIndex = int(min(center + radius, usedLength));

    float sum = 0.0;

    for (int i = minIndex; i < maxIndex; i++) {
        sum += audioSpectrum[i];
    }

    return sum / (radius / 2.0);
}

float auh(float x, float y) {
    float usedLength = float(audioSpectrumLength) / 2.0;
    float center = x * usedLength + usedLength;
    float radius = (y * usedLength) / 2.0 + usedLength;
    int minIndex = int(max(center - radius, usedLength));
    int maxIndex = int(min(center + radius, float(audioSpectrumLength)));

    float sum = 0.0;

    for (int i = minIndex; i < maxIndex; i++) {
        sum += audioSpectrum[i];
    }

    return sum / (radius / 2.0);
}

float bri(float x, float y) {
    float xFloor = floor(x);
    float yFloor = floor(y);

    float xRemainder = x - xFloor;
    float yRemainder = y - yFloor;

    if (int(xFloor) % 2 != 0) x = 1.0 - xRemainder;
    if (int(yFloor) % 2 != 0) y = 1.0 - yRemainder;

    vec2 uv = vec2(x, y);
    vec3 rgb = texture2D(image, uv).rgb;

    float brightness = (0.2126 * rgb.r + 0.7152 * rgb.g + 0.0722 * rgb.b);
    return brightness;
}

float var(float x) {
    int varIndex = int(round(x * float(nVariables)));

    if (varIndex >= nVariables) {
        varIndex = nVariables - 1;
    }

    return variables[varIndex];
}

float add(float a, float b) { return a + b; }

float sub(float a, float b) { return a - b; }

float mul(float a, float b) { return a * b; }

float div(float a, float b) { return a / b; }

vec3 generateRGB(float x, float y) {
    float r = tan(tan(min(min(sin(0.15070963),0.60627127),aud(noi(tan(min(mod(mod(cos(aud(0.018352509,y)),max(x,cos(0.9202137))),pow(0.24264526,min(cos(0.23456049),0.041949987))),tan(max(cos(aud(0.7368705,0.58583784)),min(0.12700891,y))))),mod(noi(tan(max(pow(pow(x,tan(x)),y),aud(tan(0.5340593),tan(y)))),aud(pow(aud(max(y,x),mod(0.043478012,0.31424546)),aud(tan(0.26052046),noi(x,x))),tan(aud(max(y,0.020992756),aud(0.16437626,y))))),x)),mod(0.93469167,aud(y,mod(min(tan(x),y),x)))))));
    float g = tan(tan(min(min(sin(x),y),aud(noi(tan(min(mod(mod(cos(aud(0.49854064,0.030090809)),max(0.9794917,cos(y))),pow(y,min(cos(x),x))),tan(max(cos(aud(x,0.84323454)),min(x,0.62161493))))),mod(noi(tan(max(pow(pow(0.46453023,tan(x)),y),aud(tan(x),tan(0.53473234)))),aud(pow(aud(max(x,x),mod(0.4201584,y)),aud(tan(y),noi(0.8875637,0.841908))),tan(aud(max(x,x),aud(y,x))))),0.5803399)),mod(y,aud(0.27785015,mod(min(tan(y),0.9071393),1.0)))))));
    float b = tan(tan(min(min(sin(x),y),aud(noi(tan(min(mod(mod(cos(aud(0.20155883,x)),max(x,cos(0.5417869))),pow(x,min(cos(0.8659766),y))),tan(max(cos(aud(0.71296453,x)),min(x,x))))),mod(noi(tan(max(pow(pow(x,tan(x)),x),aud(tan(y),tan(y)))),aud(pow(aud(max(y,1.0),mod(y,y)),aud(tan(0.8250809),noi(0.5852337,x))),tan(aud(max(x,y),aud(0.9238844,0.77325964))))),x)),mod(y,aud(0.103592396,mod(min(tan(y),0.23375535),x)))))));
    return vec3(r, g, b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);
    gl_FragColor = vec4(RGB, 1.0);
}
