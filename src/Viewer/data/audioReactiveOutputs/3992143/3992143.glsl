/* ############################
Evolved using software @ https://github.com/cdvetal/EvolvingInteractiveImages

// 2024 - 8 - 24

// Generation: 4
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
    float r = min(max(sub(sub(aud(mod(min(min(x,max(0.38499975,y)),add(x,noi(x,0.00884366))),sub(mul(max(noi(0.18080711,x),noi(y,x)),y),0.5403321)),y),sub(mul(0.5617838,0.92790556),mod(mul(pow(pow(0.06518936,0.14940453),cos(1.0)),cos(x)),0.7644229))),0.72511196),mod(tan(max(pow(pow(noi(noi(0.5062506,0.99827385),y),0.8462925),max(pow(tan(y),max(1.0,0.9494505)),0.8330419)),div(add(aud(tan(y),min(0.5029104,0.07220507)),tan(div(y,x))),sub(pow(aud(0.85998964,0.66935825),noi(x,y)),mod(cos(0.665503),min(y,y)))))),sin(add(0.73989606,cos(mul(tan(y),mod(0.5184288,tan(0.29698086)))))))),sin(tan(x)));
    float g = min(max(sub(sub(aud(mod(min(min(y,max(x,y)),add(x,noi(y,y))),sub(mul(max(noi(x,x),noi(x,x)),0.43066692),x)),x),sub(mul(x,x),mod(mul(pow(pow(y,y),cos(x)),cos(x)),y))),y),mod(tan(max(pow(pow(noi(noi(x,0.71110463),x),y),max(pow(tan(y),max(x,0.63403106)),0.2894702)),div(add(aud(tan(1.0),min(x,0.26246858)),tan(div(x,x))),sub(pow(aud(0.18020344,x),noi(0.20229125,0.7888062)),mod(cos(x),min(y,y)))))),sin(add(0.880975,cos(mul(tan(y),mod(0.45924687,tan(y)))))))),sin(tan(y)));
    float b = min(max(sub(sub(aud(mod(min(min(y,max(1.0,x)),add(y,noi(0.5798216,x))),sub(mul(max(noi(0.2833333,x),noi(y,x)),y),0.8299804)),x),sub(mul(y,0.30653095),mod(mul(pow(pow(y,x),cos(x)),cos(x)),y))),0.9287021),mod(tan(max(pow(pow(noi(noi(y,y),y),y),max(pow(tan(y),max(0.07705164,0.8667221)),x)),div(add(aud(tan(y),min(y,y)),tan(div(0.35896802,0.956053))),sub(pow(aud(x,0.51467395),noi(0.39526653,x)),mod(cos(y),min(y,0.2731986)))))),sin(add(y,cos(mul(tan(x),mod(y,tan(y)))))))),sin(tan(y)));
    return vec3(r, g, b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);
    gl_FragColor = vec4(RGB, 1.0);
}
