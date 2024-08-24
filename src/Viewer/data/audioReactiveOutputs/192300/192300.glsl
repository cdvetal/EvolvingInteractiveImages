/* ############################
Evolved using software @ https://github.com/cdvetal/EvolvingInteractiveImages

// 2024 - 8 - 24

// Generation: 2
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
    float r = sub(add(add(x,sub(cos(tan(div(aud(max(div(1.0,add(y,x)),max(var(y),sin(tan(sub(max(0.38971663,0.10770202),sin(x)))))),sub(div(y,x),sub(x,x))),x))),min(mul(x,max(mul(sub(mul(aud(y,sin(aud(var(x),x))),sin(tan(cos(sin(x))))),sin(div(cos(sin(min(1.0,0.25226974))),x))),0.5053251),tan(aud(x,aud(mul(y,y),y))))),div(y,mul(var(div(sin(x),add(mul(0.34382248,aud(var(x),x)),tan(aud(div(mul(y,y),y),min(mul(x,x),y)))))),var(add(add(x,div(div(max(min(y,0.8941257),y),aud(x,y)),y)),add(tan(mul(min(max(0.0015721321,0.36375284),max(x,x)),cos(0.7963271))),var(min(min(min(y,0.6391413),sub(0.8324051,y)),sin(0.4830377))))))))))),aud(cos(aud(aud(0.40274143,0.6166749),var(div(max(x,0.12277269),y)))),mul(cos(y),add(div(var(aud(x,var(x))),add(sub(aud(tan(sub(cos(0.23121262),tan(aud(sub(y,0.7903166),sub(0.34430766,0.7374196))))),sub(sin(add(div(x,y),aud(0.69896173,mul(x,0.5555768)))),tan(add(x,mul(sub(0.6337824,y),aud(0.12221217,y)))))),0.9490094),y)),sin(cos(x)))))),sub(0.6612363,min(mul(tan(min(mul(sin(add(sub(add(var(sub(max(x,x),var(y))),sin(y)),y),sub(0.72747445,y))),aud(div(0.7928951,cos(add(cos(tan(y)),y))),tan(y))),cos(cos(mul(aud(0.60693216,div(x,add(sub(0.91257524,tan(0.7177124)),tan(y)))),var(0.53865266)))))),tan(min(div(tan(y),x),mul(mul(sin(sin(min(add(add(max(div(0.6785636,x),max(x,x)),x),sub(x,x)),x))),x),y)))),mul(sin(sub(aud(var(y),y),cos(min(aud(mul(0.8814459,sin(div(add(div(y,x),aud(1.0,0.14562058)),0.16824007))),cos(min(x,aud(div(max(x,0.4934721),tan(0.708652)),sin(x))))),cos(0.63276315))))),tan(0.99779177)))));
    float g = sub(add(add(y,sub(cos(tan(div(aud(max(div(x,add(x,x)),max(var(x),sin(tan(sub(max(y,x),sin(y)))))),sub(div(0.35427237,y),sub(0.1958878,x))),y))),min(mul(y,max(mul(sub(mul(aud(x,sin(aud(var(x),y))),sin(tan(cos(sin(x))))),sin(div(cos(sin(min(0.062154293,0.0051956177))),x))),0.27093458),tan(aud(0.9519181,aud(mul(x,0.690711),0.33774805))))),div(x,mul(var(div(sin(x),add(mul(0.5551629,aud(var(0.5317898),0.29351807)),tan(aud(div(mul(0.8076639,y),0.71561885),min(mul(x,0.19457388),y)))))),var(add(add(x,div(div(max(min(x,0.038831234),0.59861326),aud(y,x)),y)),add(tan(mul(min(max(x,0.3672912),max(x,y)),cos(y))),var(min(min(min(y,0.8209865),sub(x,y)),sin(x))))))))))),aud(cos(aud(aud(0.76075935,0.9637499),var(div(max(0.018901587,x),0.19724154)))),mul(cos(y),add(div(var(aud(0.9201622,var(y))),add(sub(aud(tan(sub(cos(0.5995605),tan(aud(sub(y,x),sub(0.45089865,0.01266408))))),sub(sin(add(div(x,y),aud(y,mul(0.885159,x)))),tan(add(x,mul(sub(x,0.885695),aud(0.9768026,0.3892393)))))),y),x)),sin(cos(x)))))),sub(1.0,min(mul(tan(min(mul(sin(add(sub(add(var(sub(max(y,x),var(0.35746622))),sin(0.032957554)),x),sub(x,y))),aud(div(x,cos(add(cos(tan(0.3804109)),x))),tan(x))),cos(cos(mul(aud(y,div(x,add(sub(x,tan(0.3817463)),tan(y)))),var(x)))))),tan(min(div(tan(0.8345046),y),mul(mul(sin(sin(min(add(add(max(div(x,x),max(x,x)),y),sub(y,y)),y))),0.07393813),0.46629477)))),mul(sin(sub(aud(var(0.901062),x),cos(min(aud(mul(y,sin(div(add(div(x,y),aud(0.8442035,y)),y))),cos(min(x,aud(div(max(y,1.0),tan(x)),sin(x))))),cos(0.14004564))))),tan(y)))));
    float b = sub(add(add(x,sub(cos(tan(div(aud(max(div(0.34812784,add(x,y)),max(var(y),sin(tan(sub(max(0.026261806,x),sin(x)))))),sub(div(x,y),sub(x,x))),0.013138056))),min(mul(x,max(mul(sub(mul(aud(0.56877255,sin(aud(var(x),0.4119637))),sin(tan(cos(sin(1.0))))),sin(div(cos(sin(min(y,0.7784569))),0.090146065))),x),tan(aud(x,aud(mul(y,x),y))))),div(0.8996527,mul(var(div(sin(x),add(mul(y,aud(var(0.9883871),x)),tan(aud(div(mul(0.9762993,x),y),min(mul(0.52745104,y),y)))))),var(add(add(0.3772204,div(div(max(min(x,x),y),aud(x,0.7118912)),0.63442206)),add(tan(mul(min(max(x,0.49152374),max(y,y)),cos(x))),var(min(min(min(y,0.4720044),sub(x,y)),sin(0.71235347))))))))))),aud(cos(aud(aud(0.28141165,y),var(div(max(0.9419787,x),0.29738665)))),mul(cos(x),add(div(var(aud(x,var(y))),add(sub(aud(tan(sub(cos(0.51287436),tan(aud(sub(x,0.47530746),sub(y,x))))),sub(sin(add(div(x,x),aud(y,mul(0.85564756,x)))),tan(add(x,mul(sub(0.86383915,x),aud(x,y)))))),x),y)),sin(cos(x)))))),sub(x,min(mul(tan(min(mul(sin(add(sub(add(var(sub(max(x,x),var(0.7612047))),sin(x)),y),sub(0.22518969,0.88724256))),aud(div(0.001452446,cos(add(cos(tan(0.16278076)),y))),tan(y))),cos(cos(mul(aud(y,div(x,add(sub(0.8455572,tan(y)),tan(0.4022503)))),var(y)))))),tan(min(div(tan(x),0.850065),mul(mul(sin(sin(min(add(add(max(div(x,x),max(x,x)),x),sub(y,y)),x))),0.93813586),x)))),mul(sin(sub(aud(var(y),y),cos(min(aud(mul(x,sin(div(add(div(x,y),aud(x,y)),0.6550269))),cos(min(x,aud(div(max(y,0.80515385),tan(x)),sin(y))))),cos(y))))),tan(0.8162775)))));
    return vec3(r, g, b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);
    gl_FragColor = vec4(RGB, 1.0);
}
