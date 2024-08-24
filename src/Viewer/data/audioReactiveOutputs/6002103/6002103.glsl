/* ############################
Evolved using software @ https://github.com/cdvetal/EvolvingInteractiveImages

// 2024 - 8 - 24

// Generation: 15
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
    float r = pow(aud(sub(mul(cos(pow(noi(noi(noi(x,0.31747603),min(0.54939294,x)),add(x,noi(x,0.00884366))),add(div(0.56200194,x),0.30339837))),sub(add(0.5617838,0.7587824),noi(mul(pow(mod(0.65049124,0.40077353),cos(0.91627765)),cos(x)),0.6992526))),0.35836434),noi(cos(aud(pow(pow(noi(aud(0.4603448,0.8379648),0.1721754),0.6957185),tan(noi(max(y,0.8248832),tan(0.9404361)))),mul(mul(min(tan(y),min(0.5029104,0.74159837)),tan(div(y,y))),add(min(tan(0.85998964),mod(x,y)),pow(cos(0.9501784),max(y,y)))))),div(add(0.69241595,div(div(aud(y,y),mod(0.28072262,cos(0.29698086))),y)),x))),mul(tan(x),aud(div(mod(add(x,max(mul(min(1.0,y),y),x)),add(x,x)),y),0.46723723)));
    float g = pow(aud(sub(mul(cos(pow(noi(noi(noi(0.8186693,x),min(x,y)),add(y,noi(y,x))),add(div(x,x),x))),sub(add(x,x),noi(mul(pow(mod(x,0.11342406),cos(x)),cos(x)),y))),y),noi(cos(aud(pow(pow(noi(aud(x,0.95091534),x),x),tan(noi(max(y,x),tan(y)))),mul(mul(min(tan(0.8951118),min(x,0.44189548)),tan(div(x,0.865088))),add(min(tan(0.18020344),mod(y,0.5319071)),pow(cos(x),max(x,y)))))),div(add(0.69604635,div(div(aud(y,y),mod(0.45924687,cos(x))),0.32379723)),y))),mul(tan(y),aud(div(mod(add(0.9657779,max(mul(min(y,y),0.10611153),0.8698287)),add(x,x)),y),y)));
    float b = pow(aud(sub(mul(cos(pow(noi(noi(noi(0.24275827,x),min(0.99124813,x)),add(0.16126657,noi(0.30419207,x))),add(div(x,x),0.59734464))),sub(add(x,0.12869692),noi(mul(pow(mod(0.45817256,x),cos(x)),cos(x)),y))),0.57181454),noi(cos(aud(pow(pow(noi(aud(y,x),y),x),tan(noi(max(y,y),tan(0.35071087)))),mul(mul(min(tan(x),min(y,y)),tan(div(0.14861989,y))),add(min(tan(x),mod(0.45330834,x)),pow(cos(y),max(0.36576915,0.32974005)))))),div(add(x,div(div(aud(x,x),mod(y,cos(y))),x)),0.21520495))),mul(tan(0.11887932),aud(div(mod(add(y,max(mul(min(0.6627989,x),y),y)),add(0.6111076,0.39695907)),0.9195199),x)));
    return vec3(r, g, b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);
    gl_FragColor = vec4(RGB, 1.0);
}
