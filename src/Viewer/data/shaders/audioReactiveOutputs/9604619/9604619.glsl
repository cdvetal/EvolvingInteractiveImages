/* ############################
Evolved using software @ https://github.com/cdvetal/EvolvingInteractiveImages

// 2024 - 8 - 23

// Generation: 2
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
    float r = sub(div(aud(add(mul(div(aud(tan(x),y),y),sin(sub(pow(pow(x,add(0.96206236,add(y,y))),y),mul(x,tan(aud(add(y,0.35968637),y)))))),0.7875099),tan(y)),sin(aud(div(sin(sub(pow(0.08616853,y),aud(cos(tan(sub(y,0.45743346))),sub(0.41526175,sub(pow(0.020838976,0.35463405),aud(x,y)))))),cos(sub(0.7812433,0.043797493))),tan(cos(sin(cos(add(cos(sub(0.9188831,x)),cos(sin(0.11681008)))))))))),0.697279);
    float g = sub(div(aud(add(mul(div(aud(tan(0.3767469),0.3796296),0.1280551),sin(sub(pow(pow(0.9109106,add(y,add(x,0.38140035))),y),mul(0.58044434,tan(aud(add(0.2780633,y),y)))))),0.43074632),tan(x)),sin(aud(div(sin(sub(pow(0.49056125,y),aud(cos(tan(sub(y,x))),sub(y,sub(pow(0.3757348,0.33912134),aud(y,y)))))),cos(sub(x,x))),tan(cos(sin(cos(add(cos(sub(0.95470333,y)),cos(sin(0.18187284)))))))))),y);
    float b = sub(div(aud(add(mul(div(aud(tan(0.4143796),x),y),sin(sub(pow(pow(0.8856082,add(x,add(1.0,0.5572815))),x),mul(y,tan(aud(add(0.18680668,y),x)))))),x),tan(x)),sin(aud(div(sin(sub(pow(y,0.6120472),aud(cos(tan(sub(0.32872438,y))),sub(0.2922449,sub(pow(0.9977884,0.12853003),aud(0.64425325,y)))))),cos(sub(y,x))),tan(cos(sin(cos(add(cos(sub(y,x)),cos(sin(y)))))))))),y);
    return vec3(r, g, b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);
    gl_FragColor = vec4(RGB, 1.0);
}
