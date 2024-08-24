/* ############################
Evolved using software @ https://github.com/cdvetal/EvolvingInteractiveImages

// 2024 - 8 - 24

// Generation: 0
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
    float r = var(sin(var(aud(sub(cos(mul(tan(aud(mul(y,x),y)),mul(div(x,aud(var(aud(0.6187582,add(div(0.8699503,x),add(y,0.66781545)))),cos(sub(min(div(y,x),add(0.24221563,0.23923588)),sin(div(y,y)))))),div(sub(y,cos(mul(div(add(y,x),0.8359623),y))),aud(sin(cos(cos(max(0.45559478,0.24357438)))),max(aud(sin(cos(y)),min(cos(x),tan(y))),y)))))),0.98180103),div(0.43854332,var(tan(div(var(sub(sin(sin(add(mul(y,0.034036636),x))),min(0.88413334,add(add(sub(x,y),0.20612001),cos(x))))),cos(aud(max(mul(min(div(0.9885111,0.9055884),div(y,x)),max(x,aud(0.38324833,0.53479695))),mul(var(x),y)),div(div(max(aud(y,x),aud(x,y)),mul(mul(x,y),tan(x))),x)))))))))));
    float g = var(sin(var(aud(sub(cos(mul(tan(aud(mul(y,x),y)),mul(div(0.13208961,aud(var(aud(x,add(div(0.700027,y),add(y,x)))),cos(sub(min(div(0.62165856,x),add(0.50588226,x)),sin(div(x,x)))))),div(sub(y,cos(mul(div(add(0.5419061,x),0.18300676),x))),aud(sin(cos(cos(max(x,x)))),max(aud(sin(cos(0.44460726)),min(cos(x),tan(y))),y)))))),0.72759104),div(0.05212426,var(tan(div(var(sub(sin(sin(add(mul(y,0.90686893),y))),min(x,add(add(sub(y,y),y),cos(y))))),cos(aud(max(mul(min(div(y,y),div(y,0.03652382)),max(x,aud(0.85058975,x))),mul(var(0.26665592),x)),div(div(max(aud(y,y),aud(0.55386066,y)),mul(mul(y,x),tan(0.5302906))),0.7655852)))))))))));
    float b = var(sin(var(aud(sub(cos(mul(tan(aud(mul(x,0.5538881),x)),mul(div(x,aud(var(aud(x,add(div(x,x),add(x,x)))),cos(sub(min(div(y,0.2454977),add(y,y)),sin(div(x,y)))))),div(sub(0.63620186,cos(mul(div(add(x,x),y),0.2119112))),aud(sin(cos(cos(max(0.70183516,y)))),max(aud(sin(cos(x)),min(cos(0.8868656),tan(x))),y)))))),0.47209597),div(0.82838035,var(tan(div(var(sub(sin(sin(add(mul(0.43290877,x),y))),min(x,add(add(sub(y,x),y),cos(0.09965801))))),cos(aud(max(mul(min(div(0.83365774,0.42390466),div(x,x)),max(x,aud(x,0.6453314))),mul(var(x),x)),div(div(max(aud(x,y),aud(y,y)),mul(mul(y,0.16328454),tan(x))),x)))))))))));
    return vec3(r, g, b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);
    gl_FragColor = vec4(RGB, 1.0);
}
