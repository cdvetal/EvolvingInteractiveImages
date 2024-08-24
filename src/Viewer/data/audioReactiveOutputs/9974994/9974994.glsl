/* ############################
Evolved using software @ https://github.com/cdvetal/EvolvingInteractiveImages

// 2024 - 8 - 23

// Generation: 5
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
    float r = sin(div(sub(x,add(mul(sin(cos(aud(x,mul(x,add(bri(y,y),mul(y,x)))))),aud(aud(sin(cos(aud(y,0.06590414))),y),add(x,sin(aud(y,x))))),div(aud(add(aud(add(pow(sub(x,x),mul(x,y)),0.8389621),cos(div(add(y,0.2872057),0.76703644))),x),div(y,mul(mul(mul(cos(x),mul(x,x)),div(add(0.7270231,y),0.7833271)),mul(cos(y),cos(y))))),sin(sub(x,mul(add(sin(sin(0.533062)),0.51650643),add(aud(div(0.83122563,y),x),pow(0.9417834,aud(x,x))))))))),0.67049956));
    float g = sin(div(sub(0.14390802,add(mul(sin(cos(aud(0.2540698,mul(y,add(bri(x,0.96202564),mul(y,x)))))),aud(aud(sin(cos(aud(x,y))),y),add(0.9477036,sin(aud(y,x))))),div(aud(add(aud(add(pow(sub(y,0.28658152),mul(0.43367958,x)),y),cos(div(add(y,x),x))),x),div(x,mul(mul(mul(cos(0.3068316),mul(y,y)),div(add(y,x),0.24796748)),mul(cos(0.47161674),cos(y))))),sin(sub(x,mul(add(sin(sin(x)),y),add(aud(div(x,y),y),pow(y,aud(x,0.30721402))))))))),0.3445115));
    float b = sin(div(sub(y,add(mul(sin(cos(aud(y,mul(0.25738883,add(bri(0.08778381,0.3035562),mul(x,y)))))),aud(aud(sin(cos(aud(x,y))),0.54877806),add(y,sin(aud(0.4164989,y))))),div(aud(add(aud(add(pow(sub(y,x),mul(y,x)),y),cos(div(add(0.49677968,0.04078245),y))),x),div(0.48783922,mul(mul(mul(cos(y),mul(x,y)),div(add(x,y),y)),mul(cos(0.38517714),cos(x))))),sin(sub(0.9803567,mul(add(sin(sin(x)),0.2559774),add(aud(div(1.0,x),0.30427623),pow(y,aud(y,0.15926266))))))))),0.5797775));
    return vec3(r, g, b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);
    gl_FragColor = vec4(RGB, 1.0);
}
