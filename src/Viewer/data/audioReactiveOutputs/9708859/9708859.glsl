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
    float r = mod(min(sub(sin(tan(pow(min(min(mod(x,0.31747603),max(0.38499975,y)),add(x,noi(x,0.00884366))),add(div(0.56200194,sub(x,x)),0.5512147)))),0.5359602),pow(max(max(pow(mod(cos(cos(add(x,0.7562742))),0.99709845),tan(noi(max(y,0.7592778),tan(0.9404361)))),div(sub(aud(tan(y),pow(mod(x,0.8462925),aud(x,x))),cos(sin(y))),add(min(tan(0.85998964),noi(x,y)),noi(cos(0.9501784),max(y,y))))),x),sin(div(0.47793007,tan(div(tan(y),mod(0.5747144,cos(0.11313629)))))))),div(aud(x,x),tan(div(mod(add(x,max(div(max(0.98547196,0.02870512),y),x)),sub(y,x)),y))));
    float g = mod(min(sub(sin(tan(pow(min(min(mod(0.67565536,x),max(x,y)),add(y,noi(y,y))),add(div(x,sub(x,0.7023027)),x)))),y),pow(max(max(pow(mod(cos(cos(add(x,y))),y),tan(noi(max(y,x),tan(y)))),div(sub(aud(tan(0.86512566),pow(mod(x,y),aud(x,x))),cos(sin(x))),add(min(tan(0.18020344),noi(0.06920171,0.7888062)),noi(cos(x),max(x,y))))),x),sin(div(0.69604635,tan(div(tan(y),mod(0.45924687,cos(y)))))))),div(aud(y,x),tan(div(mod(add(0.9041252,max(div(max(0.45527196,y),0.24661851),0.6481924)),sub(x,x)),y))));
    float b = mod(min(sub(sin(tan(pow(min(min(mod(0.24275827,x),max(0.99124813,x)),add(y,noi(0.5798216,x))),add(div(x,sub(y,x)),0.5286977)))),0.89055634),pow(max(max(pow(mod(cos(cos(add(x,0.7244375))),y),tan(noi(max(y,y),tan(0.32937908)))),div(sub(aud(tan(x),pow(mod(x,0.036085606),aud(x,0.7652645))),cos(sin(0.21681523))),add(min(tan(x),noi(0.39526653,x)),noi(cos(y),max(0.3688295,0.09090781))))),y),sin(div(y,tan(div(tan(x),mod(y,cos(y)))))))),div(aud(0.28291512,x),tan(div(mod(add(y,max(div(max(0.5148897,x),y),y)),sub(0.74168444,0.6620872)),0.94304967))));
    return vec3(r, g, b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);
    gl_FragColor = vec4(RGB, 1.0);
}
