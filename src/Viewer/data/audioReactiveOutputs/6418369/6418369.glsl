/* ############################
Evolved using software @ https://github.com/cdvetal/EvolvingInteractiveImages

// 2024 - 8 - 24

// Generation: 4
// Population Size: 24; Elite Size: 1; Mutation Rate: 0.4; Crossover Rate: 0.3; Tournament Size: 3
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
    float r = mul(tan(div(cos(max(tan(cos(0.21673942)),div(0.69247913,cos(0.270586)))),min(add(mul(cos(sin(mul(y,y))),max(mul(0.3543191,sin(0.10340309)),aud(tan(x),0.8064301))),x),0.36388826))),tan(div(mul(add(x,mul(add(aud(sub(0.9370079,y),sub(0.73501873,0.3667686)),cos(div(x,x))),y)),max(min(div(0.915972,add(sin(0.4023931),add(0.46078086,y))),sub(mul(div(0.92184854,0.8124652),0.042693615),min(mul(x,y),x))),add(y,aud(sin(0.15635872),cos(add(y,0.081949234)))))),0.9330864)));
    float g = mul(tan(div(cos(max(tan(cos(y)),div(x,cos(x)))),min(add(mul(cos(sin(mul(x,y))),max(mul(0.24982476,sin(y)),aud(tan(0.566756),x))),y),0.34904957))),tan(div(mul(add(x,mul(add(aud(sub(y,y),sub(y,x)),cos(div(x,x))),0.35529208)),max(min(div(0.78013086,add(sin(x),add(y,x))),sub(mul(div(0.26016283,y),y),min(mul(y,x),x))),add(0.403692,aud(sin(x),cos(add(0.21998405,0.2680893)))))),y)));
    float b = mul(tan(div(cos(max(tan(cos(y)),div(y,cos(y)))),min(add(mul(cos(sin(mul(x,y))),max(mul(y,sin(0.25626206)),aud(tan(x),0.72420716))),0.7834065),y))),tan(div(mul(add(x,mul(add(aud(sub(x,0.0026478767),sub(0.3067212,y)),cos(div(0.083351135,1.0))),0.6618109)),max(min(div(0.29120088,add(sin(0.6113913),add(x,x))),sub(mul(div(0.705338,x),x),min(mul(y,x),y))),add(x,aud(sin(x),cos(add(y,x)))))),y)));
    return vec3(r, g, b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);
    gl_FragColor = vec4(RGB, 1.0);
}
