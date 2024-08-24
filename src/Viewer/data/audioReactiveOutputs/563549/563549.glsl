/* ############################
Evolved using software @ https://github.com/cdvetal/EvolvingInteractiveImages

// 2024 - 8 - 24

// Generation: 3
// Population Size: 23; Elite Size: 1; Mutation Rate: 0.4; Crossover Rate: 0.3; Tournament Size: 4
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
    float r = mul(mul(0.0596478,max(sin(bri(tan(div(sin(min(y,0.82638144)),cos(cos(0.9780085)))),var(max(aud(var(add(x,y)),max(x,0.1067245)),pow(pow(x,y),add(0.119739056,x)))))),max(x,x))),pow(div(y,add(div(aud(tan(var(add(y,aud(x,x)))),mul(min(pow(aud(x,x),tan(x)),var(aud(x,0.64492035))),mul(var(0.5660567),max(aud(x,x),0.69285893)))),sub(max(sin(cos(bri(x,x))),div(sub(bri(x,x),max(0.4979596,x)),x)),add(div(var(var(x)),sub(sub(x,0.5914147),x)),x))),aud(y,0.8074076))),x));
    float g = mul(mul(x,max(sin(bri(tan(div(sin(min(0.9034126,y)),cos(cos(y)))),var(max(aud(var(add(x,y)),max(y,x)),pow(pow(x,x),add(y,0.65090275)))))),max(x,0.59965277))),pow(div(0.9370456,add(div(aud(tan(var(add(0.10496664,aud(x,x)))),mul(min(pow(aud(y,x),tan(x)),var(aud(x,y))),mul(var(0.49239635),max(aud(x,x),y)))),sub(max(sin(cos(bri(x,x))),div(sub(bri(x,x),max(0.11523008,x)),x)),add(div(var(var(x)),sub(sub(x,x),x)),y))),aud(x,x))),0.16879487));
    float b = mul(mul(x,max(sin(bri(tan(div(sin(min(x,x)),cos(cos(0.7694545)))),var(max(aud(var(add(y,x)),max(0.42910957,0.2512331)),pow(pow(0.4721651,0.86526346),add(x,x)))))),max(x,x))),pow(div(x,add(div(aud(tan(var(add(x,aud(x,x)))),mul(min(pow(aud(y,x),tan(x)),var(aud(x,y))),mul(var(0.10126281),max(aud(x,x),x)))),sub(max(sin(cos(bri(x,x))),div(sub(bri(x,x),max(y,x)),x)),add(div(var(var(x)),sub(sub(x,y),x)),0.6495056))),aud(0.073361635,y))),x));
    return vec3(r, g, b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);
    gl_FragColor = vec4(RGB, 1.0);
}
