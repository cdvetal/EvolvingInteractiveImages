/* ############################
Evolved using software @ https://github.com/cdvetal/EvolvingInteractiveImages

// 2024 - 8 - 24

// Generation: 11
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
    float r = pow(max(sub(sin(cos(pow(max(mod(pow(x,0.31747603),max(0.38499975,y)),add(x,noi(min(x,0.6691263),0.00884366))),sub(x,0.5512147)))),1.0),mod(tan(max(pow(mod(max(min(0.5010922,0.99827385),0.7136097),1.0),cos(mod(aud(y,0.7592778),max(0.9404361,0.3351133)))),sub(mul(max(tan(y),tan(0.54933596)),aud(cos(y),y)),mul(noi(tan(0.85998964),mod(x,y)),noi(aud(1.0,0.33133984),aud(y,y)))))),sin(div(0.6502321,tan(sin(tan(y))))))),mul(aud(x,x),tan(div(pow(mul(x,min(mul(max(0.98547196,y),y),x)),add(y,x)),y))));
    float g = pow(max(sub(sin(cos(pow(max(mod(pow(1.0,x),max(x,y)),add(y,noi(min(x,x),y))),sub(y,x)))),y),mod(tan(max(pow(mod(max(min(x,0.93860126),x),y),cos(mod(aud(x,x),max(x,y)))),sub(mul(max(tan(0.6923065),tan(x)),aud(cos(x),x)),mul(noi(tan(0.18020344),mod(0.06920171,1.0)),noi(aud(x,x),aud(y,y)))))),sin(div(0.029696465,tan(sin(tan(y))))))),mul(aud(y,x),tan(div(pow(mul(0.9809835,min(mul(max(0.38107634,y),0.44619608),0.6481924)),add(x,x)),y))));
    float b = pow(max(sub(sin(cos(pow(max(mod(pow(0.24275827,x),max(1.0,x)),add(y,noi(min(x,y),x))),sub(x,0.5286977)))),0.81164217),mod(tan(max(pow(mod(max(min(y,y),y),y),cos(mod(aud(y,y),max(0.18213701,0.11856985)))),sub(mul(max(tan(y),tan(y)),aud(cos(0.08158159),y)),mul(noi(tan(x),mod(0.39526653,x)),noi(aud(y,x),aud(0.3688295,0.32974005)))))),sin(div(y,tan(sin(tan(y))))))),mul(aud(0.060048103,x),tan(div(pow(mul(y,min(mul(max(0.7238376,x),0.124935865),y)),add(0.74168444,0.5113487)),1.0))));
    return vec3(r, g, b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);
    gl_FragColor = vec4(RGB, 1.0);
}
