/* ############################
Evolved using software @ https://github.com/cdvetal/EvolvingInteractiveImages

// 2024 - 8 - 24

// Generation: 1
// Population Size: 24; Elite Size: 1; Mutation Rate: 0.4; Crossover Rate: 0.3; Tournament Size: 4
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
    float r = min(sub(div(sin(y),sin(div(pow(x,pow(div(y,cos(0.54718304)),sub(mul(0.5155053,x),x))),cos(var(noi(min(x,y),aud(x,y))))))),min(div(noi(pow(y,y),mod(x,sin(mul(0.84127855,min(0.060572624,y))))),x),mod(min(max(y,aud(tan(y),noi(min(x,x),0.59678435))),mod(y,min(y,sub(aud(y,0.19365287),pow(x,y))))),add(cos(x),mul(aud(max(cos(0.5768781),pow(y,0.6075127)),0.9343927),y))))),cos(aud(tan(tan(tan(pow(pow(aud(x,0.08001542),max(y,y)),0.96273327)))),mod(pow(cos(y),add(max(cos(pow(y,y)),cos(cos(x))),min(aud(sin(y),div(0.74393034,x)),div(add(y,x),cos(0.93256235))))),max(0.19655871,0.93947387)))));
    float g = min(sub(div(sin(y),sin(div(pow(0.26299524,pow(div(x,cos(x)),sub(mul(0.6400578,x),y))),cos(var(noi(min(x,0.5034065),aud(x,x))))))),min(div(noi(pow(y,0.010856628),mod(y,sin(mul(y,min(y,y))))),y),mod(min(max(0.24760485,aud(tan(0.23866582),noi(min(0.1391058,0.013416767),y))),mod(0.8474834,min(x,sub(aud(y,x),pow(x,0.484735))))),add(cos(y),mul(aud(max(cos(y),pow(0.34720445,y)),y),y))))),cos(aud(tan(tan(tan(pow(pow(aud(x,0.25920916),max(x,x)),y)))),mod(pow(cos(0.26267195),add(max(cos(pow(y,y)),cos(cos(x))),min(aud(sin(y),div(y,y)),div(add(x,x),cos(0.29322052))))),max(0.07097912,0.38719273)))));
    float b = min(sub(div(sin(x),sin(div(pow(y,pow(div(x,cos(0.074193954)),sub(mul(x,y),0.9290004))),cos(var(noi(min(y,y),aud(x,0.47967458))))))),min(div(noi(pow(x,x),mod(x,sin(mul(y,min(y,0.34770107))))),y),mod(min(max(0.15028739,aud(tan(y),noi(min(0.24634504,x),x))),mod(0.5254662,min(0.14969349,sub(aud(0.13989735,0.18521309),pow(y,0.23427844))))),add(cos(x),mul(aud(max(cos(x),pow(x,x)),0.9300375),0.5503192))))),cos(aud(tan(tan(tan(pow(pow(aud(y,y),max(0.8136625,0.62707496)),x)))),mod(pow(cos(x),add(max(cos(pow(y,y)),cos(cos(y))),min(aud(sin(y),div(x,x)),div(add(0.8363404,0.38152027),cos(y))))),max(y,0.53349423)))));
    return vec3(r, g, b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);
    gl_FragColor = vec4(RGB, 1.0);
}
