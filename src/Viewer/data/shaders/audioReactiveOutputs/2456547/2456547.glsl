/* ############################
Evolved using software @ https://github.com/cdvetal/EvolvingInteractiveImages

// 2024 - 8 - 23

// Generation: 10
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
    float r = sin(div(add(x,add(mul(div(tan(aud(x,mul(x,add(bri(y,y),mul(y,x))))),x),aud(aud(sin(tan(cos(y))),y),mul(y,x))),div(aud(add(aud(add(bri(add(x,x),mul(x,x)),0.8389621),cos(sub(add(y,0.30731726),0.76703644))),x),mul(y,mul(add(mul(div(aud(x,x),add(x,y)),div(x,x)),sub(sub(0.7465668,y),0.7833271)),sub(aud(x,x),cos(x))))),sin(sub(x,sub(add(mul(div(0.533062,0.88916063),x),0.4155221),add(tan(div(0.83122563,x)),bri(0.692816,cos(x))))))))),0.7048733));
    float g = sin(div(add(y,add(mul(div(tan(aud(0.052681923,mul(y,add(bri(x,0.7189183),mul(y,x))))),0.9026332),aud(aud(sin(tan(cos(x))),y),mul(y,y))),div(aud(add(aud(add(bri(add(y,0.1759963),mul(0.43367958,x)),y),cos(sub(add(y,x),x))),x),mul(x,mul(add(mul(div(aud(x,x),add(x,x)),div(y,0.15297103)),sub(sub(x,x),0.24796748)),sub(aud(0.208354,y),cos(y))))),sin(sub(x,sub(add(mul(div(x,x),y),y),add(tan(div(x,y)),bri(x,cos(x))))))))),0.5955813));
    float b = sin(div(add(y,add(mul(div(tan(aud(y,mul(0.25738883,add(bri(0.08778381,0.25290322),mul(x,x))))),y),aud(aud(sin(tan(cos(x))),0.54877806),mul(y,0.042196274))),div(aud(add(aud(add(bri(add(y,x),mul(y,x)),y),cos(sub(add(0.64643383,0.04078245),y))),x),mul(0.6596825,mul(add(mul(div(aud(x,x),add(x,y)),div(x,y)),sub(sub(x,y),y)),sub(aud(y,x),cos(x))))),sin(sub(1.0,sub(add(mul(div(x,y),y),0.05656314),add(tan(div(0.9206331,x)),bri(y,cos(y))))))))),0.32291555));
    return vec3(r, g, b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);
    gl_FragColor = vec4(RGB, 1.0);
}
