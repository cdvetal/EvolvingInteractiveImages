/* ############################
Evolved using software @ https://github.com/cdvetal/EvolvingInteractiveImages

// 2024 - 8 - 24

// Generation: 34
// Population Size: 18; Elite Size: 1; Mutation Rate: 0.4; Crossover Rate: 0.3; Tournament Size: 4
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
    float r = var(aud(sin(max(0.69753504,max(y,add(add(0.16539264,0.076761246),add(max(add(tan(add(0.22710967,add(add(min(x,x),min(0.5270443,y)),x))),aud(sub(var(var(aud(x,0.07402778))),0.21254754),cos(tan(add(aud(y,y),var(y)))))),x),0.81141496))))),cos(div(sub(sub(aud(tan(x),0.8362253),0.42964673),max(tan(sin(var(y))),mul(add(0.6998124,add(y,mul(tan(add(add(div(0.7878547,x),div(x,y)),tan(mul(y,0.40054083)))),tan(add(x,x))))),sin(x)))),0.054837704))));
    float g = var(aud(sin(max(0.6879983,max(x,add(add(x,x),add(max(add(tan(add(0.36289668,add(add(min(x,0.1343422),min(0.5053265,0.38262582)),x))),aud(sub(var(var(aud(x,0.527555))),y),cos(tan(add(aud(y,x),var(x)))))),0.6910331),0.8875382))))),cos(div(sub(sub(aud(tan(0.3332796),y),x),max(tan(sin(var(y))),mul(add(0.46824956,add(0.5375154,mul(tan(add(add(div(x,y),div(x,0.8271625)),tan(mul(x,y)))),tan(add(x,x))))),sin(x)))),y))));
    float b = var(aud(sin(max(x,max(x,add(add(x,x),add(max(add(tan(add(x,add(add(min(x,y),min(x,x)),x))),aud(sub(var(var(aud(0.56856394,y))),0.31543374),cos(tan(add(aud(x,x),var(y)))))),0.003499031),x))))),cos(div(sub(sub(aud(tan(0.80641556),x),0.63431716),max(tan(sin(var(x))),mul(add(x,add(x,mul(tan(add(add(div(x,0.39838815),div(x,y)),tan(mul(x,y)))),tan(add(x,x))))),sin(x)))),y))));
    return vec3(r, g, b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);
    gl_FragColor = vec4(RGB, 1.0);
}
