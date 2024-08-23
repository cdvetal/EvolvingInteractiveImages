/* ############################
Evolved using software @ https://github.com/cdvetal/EvolvingInteractiveImages

// 2024 - 8 - 23

// Generation: 4
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
    float r = sin(mul(sub(x,add(div(sin(tan(bri(x,sub(x,add(y,sub(sub(x,x),mul(x,x))))))),aud(aud(sin(tan(tan(y))),y),mul(y,x))),mul(tan(add(aud(add(pow(sub(x,x),mul(x,0.023066282)),1.0),tan(mul(add(y,0.30731726),0.94539523))),x)),div(sub(x,mul(add(div(div(0.533062,y),y),0.51650643),sub(aud(div(0.83122563,y),y),pow(1.0,aud(x,x))))),x)))),0.5460465));
    float g = sin(mul(sub(y,add(div(sin(tan(bri(0.2540698,sub(0.3000419,add(0.7980852,sub(sub(y,x),mul(x,x))))))),aud(aud(sin(tan(tan(x))),y),mul(y,y))),mul(tan(add(aud(add(pow(sub(x,0.13683176),mul(0.2682426,x)),y),tan(mul(add(y,x),x))),y)),div(sub(x,mul(add(div(div(y,0.289886),y),y),sub(aud(div(x,x),y),pow(y,aud(x,0.28762007))))),y)))),0.3915918));
    float b = sin(mul(sub(y,add(div(sin(tan(bri(y,sub(0.25738883,add(0.5581417,sub(sub(y,x),mul(x,x))))))),aud(aud(sin(tan(tan(x))),0.746053),mul(y,0.04877019))),mul(tan(add(aud(add(pow(sub(y,x),mul(y,x)),y),tan(mul(add(0.41840243,0.04078245),y))),x)),div(sub(0.9803567,mul(add(div(div(x,x),y),0.2559774),sub(aud(div(0.9206331,x),0.47129607),pow(y,aud(y,0.029571772))))),0.22585392)))),0.32139087));
    return vec3(r, g, b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);
    gl_FragColor = vec4(RGB, 1.0);
}
