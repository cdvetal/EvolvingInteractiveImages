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
    float r = sub(tan(add(x,max(x,0.19480324))),div(mul(max(tan(add(mul(x,tan(div(x,x))),aud(mul(mul(y,x),mul(x,0.47067475)),y))),x),sub(tan(add(aud(max(min(0.22350764,y),sub(x,y)),max(y,div(y,x))),sub(min(tan(y),y),add(aud(x,y),tan(0.72655535))))),sub(max(tan(0.1319623),sub(div(y,div(x,y)),0.35137367)),max(tan(div(y,add(y,y))),mul(aud(aud(x,x),sub(x,x)),tan(max(0.2759161,x))))))),max(sub(div(0.07610321,max(aud(mul(sub(0.84381247,x),max(x,0.18515992)),x),add(mul(max(x,y),add(0.5150504,y)),x))),0.4093628),mul(tan(div(aud(max(max(x,x),sub(y,x)),y),y)),div(max(min(0.7129016,mul(max(x,0.7260959),y)),y),sub(max(aud(div(y,y),tan(x)),min(min(x,y),tan(x))),min(max(mul(x,x),mul(0.9712422,x)),y)))))));
    float g = sub(tan(add(y,max(y,x))),div(mul(max(tan(add(mul(x,tan(div(0.3844247,0.07645416))),aud(mul(mul(0.6074166,0.85800934),mul(y,x)),x))),0.3420751),sub(tan(add(aud(max(min(0.35553145,0.13749146),sub(x,0.23112631)),max(y,div(y,0.8131206))),sub(min(tan(y),y),add(aud(x,y),tan(y))))),sub(max(tan(x),sub(div(y,div(y,x)),x)),max(tan(div(x,add(0.08569622,0.8834405))),mul(aud(aud(x,x),sub(y,0.3189118)),tan(max(y,0.22672248))))))),max(sub(div(y,max(aud(mul(sub(0.8263006,0.70084834),max(y,y)),0.16455317),add(mul(max(x,0.2075944),add(y,y)),0.5726228))),y),mul(tan(div(aud(max(max(y,x),sub(0.9715395,0.32018805)),0.876863),0.85587263)),div(max(min(y,mul(max(y,y),x)),0.77194023),sub(max(aud(div(y,x),tan(x)),min(min(y,y),tan(y))),min(max(mul(0.1678462,0.085826874),mul(x,0.21498013)),0.013038874)))))));
    float b = sub(tan(add(y,max(0.78559613,y))),div(mul(max(tan(add(mul(0.13921928,tan(div(0.799062,x))),aud(mul(mul(x,x),mul(0.4864664,y)),0.4644096))),0.10847187),sub(tan(add(aud(max(min(0.16488814,y),sub(0.2666781,x)),max(x,div(y,x))),sub(min(tan(y),y),add(aud(0.05027795,x),tan(y))))),sub(max(tan(y),sub(div(x,div(x,x)),x)),max(tan(div(0.48499966,add(x,y))),mul(aud(aud(0.4341457,y),sub(x,y)),tan(max(x,0.56117654))))))),max(sub(div(x,max(aud(mul(sub(x,x),max(y,x)),x),add(mul(max(x,y),add(x,x)),y))),0.55937576),mul(tan(div(aud(max(max(0.8012557,0.18421674),sub(0.7048292,y)),0.11036062),0.91162634)),div(max(min(x,mul(max(x,y),y)),y),sub(max(aud(div(0.23990297,x),tan(x)),min(min(x,0.8522117),tan(0.11447382))),min(max(mul(y,y),mul(0.91209817,0.010672092)),x)))))));
    return vec3(r, g, b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);
    gl_FragColor = vec4(RGB, 1.0);
}
