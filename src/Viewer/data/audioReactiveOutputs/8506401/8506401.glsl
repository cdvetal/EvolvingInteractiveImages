/* ############################
Evolved using software @ https://github.com/cdvetal/EvolvingInteractiveImages

// 2024 - 8 - 24

// Generation: 14
// Population Size: 18; Elite Size: 1; Mutation Rate: 0.4; Crossover Rate: 0.3; Tournament Size: 3
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
    float r = mul(sub(div(aud(min(y,aud(div(div(max(0.43504262,x),y),0.06439066),x)),min(min(x,x),max(x,aud(add(sub(0.2777729,cos(x)),div(0.6257837,y)),x)))),min(max(sub(max(cos(0.93170166),aud(mul(0.14441395,x),0.97949314)),min(min(max(y,x),0.6889069),mul(add(y,0.32684374),y))),sub(y,max(0.8390765,0.63970447))),cos(aud(add(add(sub(0.8218019,x),min(y,y)),y),cos(cos(add(x,x))))))),x),cos(sub(y,sub(mul(0.29171157,aud(cos(min(mul(y,x),cos(x))),x)),mul(x,div(add(cos(add(0.18696976,x)),cos(max(x,0.33611488))),cos(cos(0.748631))))))));
    float g = mul(sub(div(aud(min(y,aud(div(div(max(0.43025708,y),0.58345556),x),x)),min(min(x,0.6080098),max(0.72656393,aud(add(sub(x,cos(0.37906623)),div(x,y)),0.87494683)))),min(max(sub(max(cos(x),aud(mul(0.15565348,x),x)),min(min(max(x,y),y),mul(add(0.99857616,x),x))),sub(0.66790605,max(0.9981332,y))),cos(aud(add(add(sub(0.9036684,0.47905016),min(x,x)),x),cos(cos(add(y,x))))))),x),cos(sub(x,sub(mul(x,aud(cos(min(mul(0.11926222,0.8077102),cos(x))),0.4028778)),mul(y,div(add(cos(add(y,0.48289728)),cos(max(0.24936724,0.14081621))),cos(cos(x))))))));
    float b = mul(sub(div(aud(min(x,aud(div(div(max(y,0.13944769),0.73439527),0.75640297),y)),min(min(0.40192342,x),max(x,aud(add(sub(0.8127637,cos(y)),div(0.6215322,x)),x)))),min(max(sub(max(cos(0.5081272),aud(mul(x,x),0.25331044)),min(min(max(y,y),0.37660837),mul(add(0.17418051,0.24685669),x))),sub(x,max(x,0.8055835))),cos(aud(add(add(sub(x,y),min(y,0.33243108)),0.6812911),cos(cos(add(y,y))))))),x),cos(sub(y,sub(mul(0.94949555,aud(cos(min(mul(0.6978636,0.6747639),cos(x))),y)),mul(x,div(add(cos(add(0.403646,0.6652198)),cos(max(y,0.7647257))),cos(cos(y))))))));
    return vec3(r, g, b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);
    gl_FragColor = vec4(RGB, 1.0);
}
