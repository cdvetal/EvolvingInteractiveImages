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
    float r = tan(min(sin(min(0.978323,max(y,add(add(0.22434855,0.076761246),add(min(add(var(add(0.4122579,sub(sub(min(x,x),min(0.5270443,y)),y))),aud(sub(aud(aud(aud(x,0.30372596),0.6272783),x),0.14822865),tan(cos(mul(max(y,y),var(0.27462697)))))),x),0.81141496))))),var(sin(sub(mul(var(var(x)),0.35288143),aud(aud(tan(aud(y,x)),x),div(add(0.6998124,sub(y,div(var(add(mul(cos(0.7878547),div(x,y)),var(sin(y)))),max(sub(y,y),min(div(var(0.19386768),mul(0.45983815,x)),0.83174634))))),cos(y))))))));
    float g = tan(min(sin(min(0.50162864,max(x,add(add(y,x),add(min(add(var(add(0.60096073,sub(sub(min(x,0.004590988),min(0.62487626,0.38262582)),x))),aud(sub(aud(aud(aud(x,0.527555),0.85490155),x),0.05030775),tan(cos(mul(max(y,x),var(x)))))),0.6910331),0.8875382))))),var(sin(sub(mul(var(var(0.6262603)),x),aud(aud(tan(aud(0.0023725033,y)),x),div(add(0.31446123,sub(0.83551645,div(var(add(mul(cos(y),div(x,0.56516933)),var(sin(x)))),max(sub(y,x),min(div(var(y),mul(0.7197535,0.15384078)),x))))),cos(x))))))));
    float b = tan(min(sin(min(y,max(x,add(add(x,x),add(min(add(var(add(x,sub(sub(min(y,y),min(x,x)),y))),aud(sub(aud(aud(aud(0.29225063,y),y),y),0.31543374),tan(cos(mul(max(x,x),var(x)))))),0.003499031),y))))),var(sin(sub(mul(var(var(0.80641556)),0.63431716),aud(aud(tan(aud(x,x)),y),div(add(x,sub(x,div(var(add(mul(cos(y),div(y,y)),var(sin(x)))),max(sub(y,x),min(div(var(x),mul(0.12484741,x)),x))))),cos(x))))))));
    return vec3(r, g, b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);
    gl_FragColor = vec4(RGB, 1.0);
}
