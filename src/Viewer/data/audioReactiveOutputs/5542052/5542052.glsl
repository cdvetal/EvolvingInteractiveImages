/* ############################
Evolved using software @ https://github.com/cdvetal/EvolvingInteractiveImages

// 2024 - 8 - 24

// Generation: 4
// Population Size: 24; Elite Size: 2; Mutation Rate: 0.4; Crossover Rate: 0.3; Tournament Size: 4
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
    float r = noi(aud(sub(div(tan(pow(noi(min(mod(x,0.31747603),max(0.26192856,y)),add(x,noi(x,0.25429964))),add(div(0.56200194,add(x,x)),0.5512147))),add(div(0.5617838,0.70174265),noi(sub(mod(pow(0.36478877,0.14177322),tan(0.91627765)),sin(x)),0.6992526))),0.5359602),pow(aud(max(pow(mod(min(min(0.4603448,0.93980694),0.1721754),0.7907975),tan(mod(max(y,0.7592778),aud(0.9404361,x)))),mul(mul(max(cos(y),noi(0.78252196,0.54900336)),cos(mul(y,x))),add(noi(tan(1.0),noi(x,y)),mod(cos(0.9501784),aud(y,y))))),x),sin(mul(0.73989606,sin(div(cos(y),pow(0.28072262,tan(0.27240658)))))))),div(aud(x,x),tan(mul(mod(add(x,max(div(min(0.98547196,y),y),x)),mul(y,x)),y))));
    float g = noi(aud(sub(div(tan(pow(noi(min(mod(0.8186693,x),max(x,y)),add(x,noi(y,y))),add(div(x,add(x,0.7023027)),x))),add(div(x,x),noi(sub(mod(pow(y,0.11342406),tan(x)),sin(x)),y))),y),pow(aud(max(pow(mod(min(min(x,0.95091534),x),y),tan(mod(max(y,x),aud(x,y)))),mul(mul(max(cos(0.8951118),noi(x,0.39867973)),cos(mul(x,x))),add(noi(tan(0.18020344),noi(0.06920171,0.82536674)),mod(cos(x),aud(x,y))))),x),sin(mul(0.69604635,sin(div(cos(y),pow(0.45924687,tan(y)))))))),div(aud(y,x),tan(mul(mod(add(0.9041252,max(div(min(0.38107634,y),0.24661851),0.6481924)),mul(x,x)),y))));
    float b = noi(aud(sub(div(tan(pow(noi(min(mod(0.24275827,x),max(0.99124813,x)),add(y,noi(0.5798216,x))),add(div(x,add(y,x)),0.5286977))),add(div(y,0.30653095),noi(sub(mod(pow(y,x),tan(x)),sin(x)),y))),0.92463875),pow(aud(max(pow(mod(min(min(y,y),y),y),tan(mod(max(y,y),aud(0.32937908,0.17592144)))),mul(mul(max(cos(x),noi(y,y)),cos(mul(0.21681523,x))),add(noi(tan(x),noi(0.39526653,x)),mod(cos(y),aud(0.3688295,0.32974005))))),y),sin(mul(y,sin(div(cos(x),pow(y,tan(y)))))))),div(aud(0.11887932,x),tan(mul(mod(add(y,max(div(min(0.5148897,x),y),y)),mul(0.74168444,0.38094354)),0.94304967))));
    return vec3(r, g, b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);
    gl_FragColor = vec4(RGB, 1.0);
}
