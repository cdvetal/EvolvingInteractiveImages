/* ############################
Evolved using software @ https://github.com/cdvetal/EvolvingInteractiveImages

// 2024 - 8 - 24

// Generation: 3
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
    float r = sub(tan(add(y,min(x,0.19480324))),div(mul(max(tan(add(div(x,tan(div(x,x))),aud(div(div(y,x),div(x,0.47067475)),y))),x),sub(div(sub(max(max(min(0.22350764,y),add(sub(x,x),y)),max(y,div(0.2297306,x))),sub(min(div(y,x),y),sub(max(x,y),tan(0.60997915)))),0.59783554),sub(max(tan(0.1319623),sub(div(y,mul(x,y)),0.43364978)),max(tan(mul(y,add(y,y))),sub(aud(aud(x,x),sub(x,y)),div(max(0.42844582,x),0.7994983)))))),max(sub(div(0.07610321,aud(aud(mul(sub(0.84381247,x),max(x,0.13349795)),x),add(tan(max(x,y)),x))),0.4093628),mul(aud(div(aud(min(max(x,x),sub(y,x)),y),y),0.047439337),div(max(min(0.749578,mul(max(x,0.55168486),y)),y),sub(min(aud(mul(0.2723999,y),tan(x)),min(min(x,y),tan(x))),min(max(sub(x,x),mul(0.9712422,x)),y)))))));
    float g = sub(tan(add(y,min(y,x))),div(mul(max(tan(add(div(x,tan(div(0.19851065,y))),aud(div(div(0.33935165,0.85800934),div(y,x)),x))),0.23107648),sub(div(sub(max(max(min(0.35553145,0.13749146),add(sub(0.22022796,x),0.23112631)),max(y,div(y,1.0))),sub(min(div(y,0.6924982),y),sub(max(x,y),tan(y)))),0.391222),sub(max(tan(x),sub(div(y,mul(y,x)),y)),max(tan(mul(x,add(0.19434524,0.8834405))),sub(aud(aud(x,x),sub(y,0.3189118)),div(max(y,y),x)))))),max(sub(div(y,aud(aud(mul(sub(0.8263006,0.70084834),max(y,y)),0.1616087),add(tan(max(x,0.25834394)),0.5726228))),0.025417328),mul(aud(div(aud(min(max(y,x),sub(0.7186475,0.32018805)),0.876863),0.85587263),0.8072014),div(max(min(y,mul(max(y,y),x)),0.77194023),sub(min(aud(mul(y,x),tan(x)),min(min(y,y),tan(y))),min(max(sub(0.1678462,0.085826874),mul(x,0.21498013)),0.013038874)))))));
    float b = sub(tan(add(y,min(0.78559613,y))),div(mul(max(tan(add(div(0.13921928,tan(div(0.7933676,x))),aud(div(div(x,x),div(0.4864664,y)),0.26963425))),0.07447934),sub(div(sub(max(max(min(0.16488814,y),add(sub(x,x),y)),max(x,div(y,x))),sub(min(div(y,x),y),sub(max(0.05027795,x),tan(y)))),0.78581834),sub(max(tan(y),sub(div(x,mul(x,x)),x)),max(tan(mul(0.48499966,add(x,x))),sub(aud(aud(0.36223364,y),sub(x,y)),div(max(x,0.56117654),0.403589)))))),max(sub(div(x,aud(aud(mul(sub(x,x),max(y,x)),x),add(tan(max(x,y)),y))),0.7509248),mul(aud(div(aud(min(max(0.8012557,y),sub(0.96605206,0.061620474)),0.07629323),1.0),y),div(max(min(x,mul(max(x,y),y)),y),sub(min(aud(mul(0.06368399,x),tan(x)),min(min(x,0.8522117),tan(0.11447382))),min(max(sub(y,y),mul(0.91209817,y)),x)))))));
    return vec3(r, g, b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);
    gl_FragColor = vec4(RGB, 1.0);
}
