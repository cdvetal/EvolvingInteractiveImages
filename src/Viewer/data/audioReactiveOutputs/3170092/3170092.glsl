/* ############################
Evolved using software @ https://github.com/cdvetal/EvolvingInteractiveImages

// 2024 - 8 - 24

// Generation: 7
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
    float r = mul(tan(add(y,min(x,0.19480324))),mul(div(max(tan(add(div(x,tan(div(x,x))),aud(tan(mul(y,x)),y))),x),sub(div(add(max(min(max(0.22350764,y),sub(x,x)),max(y,div(y,x))),sub(min(tan(y),y),add(aud(x,y),tan(0.72655535)))),x),sub(min(tan(0.1319623),sub(tan(y),0.35137367)),max(tan(div(y,add(y,y))),mul(aud(tan(x),sub(x,x)),div(min(0.5544944,x),y)))))),max(sub(mul(0.07610321,aud(max(mul(sub(0.84381247,x),max(x,0.18515992)),x),add(div(min(x,y),add(0.5150504,y)),y))),0.4093628),mul(tan(0.7107625),div(aud(min(0.7129016,mul(max(x,0.7260959),y)),y),add(min(aud(div(y,y),aud(x,x)),min(max(x,y),div(x,0.8203888))),min(max(mul(x,x),sub(0.87213683,x)),y)))))));
    float g = mul(tan(add(y,min(y,x))),mul(div(max(tan(add(div(x,tan(div(0.3844247,0.07645416))),aud(tan(mul(0.6074166,0.85800934)),x))),0.3420751),sub(div(add(max(min(max(0.35553145,0.13749146),sub(x,0.056950808)),max(0.04031062,div(y,1.0))),sub(min(tan(y),0.11357474),add(aud(x,y),tan(y)))),x),sub(min(tan(x),sub(tan(y),x)),max(tan(div(x,add(0.08569622,0.8834405))),mul(aud(tan(x),sub(y,0.3189118)),div(min(y,y),x)))))),max(sub(mul(y,aud(max(mul(sub(0.8263006,0.70084834),max(y,y)),0.16455317),add(div(min(x,0.2075944),add(y,y)),0.83763385))),y),mul(tan(x),div(aud(min(y,mul(max(y,y),x)),0.986006),add(min(aud(div(y,x),aud(x,y)),min(max(y,y),div(y,y))),min(max(mul(0.45106125,0.085826874),sub(x,0.21498013)),y)))))));
    float b = mul(tan(add(y,min(0.86480665,y))),mul(div(max(tan(add(div(0.39749193,tan(div(0.799062,x))),aud(tan(mul(x,x)),0.4644096))),0.10847187),sub(div(add(max(min(max(0.16488814,y),sub(0.35907865,y)),max(x,div(y,x))),sub(min(tan(y),y),add(aud(0.05027795,x),tan(y)))),0.27345848),sub(min(tan(y),sub(tan(x),x)),max(tan(div(0.4695816,add(x,y))),mul(aud(tan(0.31223774),sub(x,y)),div(min(x,0.3277402),x)))))),max(sub(mul(x,aud(max(mul(sub(x,x),max(y,x)),x),add(div(min(x,y),add(x,x)),y))),0.55937576),mul(tan(0.91209817),div(aud(min(x,mul(max(y,y),y)),y),add(min(aud(div(0.23990297,x),aud(x,x)),min(max(x,1.0),div(0.16676617,x))),min(max(mul(y,y),sub(0.91209817,0.010672092)),x)))))));
    return vec3(r, g, b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);
    gl_FragColor = vec4(RGB, 1.0);
}
