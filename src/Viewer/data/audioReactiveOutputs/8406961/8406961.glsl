/* ############################
Evolved using software @ https://github.com/cdvetal/EvolvingInteractiveImages

// 2024 - 8 - 24

// Generation: 0
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
    float r = add(min(max(noi(0.57902884,0.73548675),sub(pow(pow(x,max(mul(div(y,x),tan(x)),noi(0.9651625,0.6009717))),0.864995),max(noi(min(aud(x,noi(y,x)),add(mul(0.39954567,0.22810555),pow(y,0.19686627))),0.28276753),x))),var(pow(0.2165513,aud(0.8900399,cos(x))))),max(mul(y,sub(cos(max(y,pow(var(noi(y,0.96712685)),noi(tan(x),cos(y))))),x)),max(min(div(div(sub(0.32782578,var(pow(x,x))),tan(x)),y),add(mul(min(y,div(mul(0.58311033,y),0.9373617)),pow(aud(add(y,0.18107057),mod(y,0.8561177)),max(tan(0.7759304),cos(x)))),mod(x,var(x)))),y)));
    float g = add(min(max(noi(0.17109227,0.44705606),sub(pow(pow(0.9612832,max(mul(div(x,y),tan(0.41324067)),noi(x,0.9380622))),0.59033537),max(noi(min(aud(x,noi(y,y)),add(mul(x,x),pow(y,x))),y),y))),var(pow(y,aud(x,cos(x))))),max(mul(x,sub(cos(max(x,pow(var(noi(x,y)),noi(tan(y),cos(y))))),0.96289945)),max(min(div(div(sub(x,var(pow(0.63067245,0.15728807))),tan(0.17463017)),x),add(mul(min(0.4628756,div(mul(x,0.7965014),x)),pow(aud(add(y,0.13686681),mod(x,0.73824406)),max(tan(y),cos(x)))),mod(x,var(x)))),0.40821385)));
    float b = add(min(max(noi(y,y),sub(pow(pow(0.020574093,max(mul(div(x,x),tan(0.07268953)),noi(y,y))),x),max(noi(min(aud(x,noi(y,y)),add(mul(0.53549385,x),pow(0.67076015,y))),0.76572466),y))),var(pow(y,aud(y,cos(y))))),max(mul(0.33562088,sub(cos(max(y,pow(var(noi(0.88266563,x)),noi(tan(x),cos(0.9104724))))),0.7647958)),max(min(div(div(sub(y,var(pow(0.5090475,x))),tan(y)),y),add(mul(min(y,div(mul(x,x),y)),pow(aud(add(0.13188386,0.3037362),mod(x,y)),max(tan(y),cos(0.60551)))),mod(x,var(x)))),x)));
    return vec3(r, g, b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);
    gl_FragColor = vec4(RGB, 1.0);
}
