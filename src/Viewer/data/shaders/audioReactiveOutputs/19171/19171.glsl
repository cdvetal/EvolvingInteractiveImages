/* ############################
Evolved using software @ https://github.com/cdvetal/EvolvingInteractiveImages

// 2024 - 8 - 23

// Generation: 0
// Population Size: 21; Elite Size: 1; Mutation Rate: 0.4813084; Crossover Rate: 0.41121495; Tournament Size: 3
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
    float r = noi(tan(y),aud(aud(min(noi(min(aud(mod(0.9575691,max(y,tan(aud(x,y)))),x),x),tan(y)),x),pow(min(tan(sin(max(x,cos(max(max(y,y),sin(x)))))),min(0.24138904,0.6383457)),y)),aud(x,pow(mod(noi(noi(mod(min(noi(aud(x,y),max(0.13497329,0.5817437)),min(cos(x),mod(x,x))),tan(sin(pow(x,x)))),sin(cos(pow(x,cos(0.18425274))))),max(mod(x,max(min(min(y,y),cos(x)),tan(min(x,0.9952977)))),tan(aud(x,0.18277025)))),pow(mod(0.7990625,pow(tan(0.3666215),sin(0.3059497))),tan(pow(max(max(aud(x,0.66529584),y),y),0.81931996)))),min(y,pow(tan(max(mod(aud(max(0.673537,0.7712736),max(x,x)),pow(0.36634707,0.866153)),y)),y))))));
    float g = noi(tan(x),aud(aud(min(noi(min(aud(mod(y,max(x,tan(aud(x,0.030659199)))),y),x),tan(y)),0.6721549),pow(min(tan(sin(max(0.14092946,cos(max(max(x,0.9616859),sin(0.2622075)))))),min(0.6669135,y)),x)),aud(0.5444913,pow(mod(noi(noi(mod(min(noi(aud(y,0.5077238),max(0.441931,x)),min(cos(y),mod(y,0.5930815))),tan(sin(pow(x,y)))),sin(cos(pow(0.26941514,cos(x))))),max(mod(0.9794917,max(min(min(0.37569618,x),cos(0.7660425)),tan(min(x,y)))),tan(aud(y,x)))),pow(mod(y,pow(tan(y),sin(y))),tan(pow(max(max(aud(0.28798342,x),x),0.5916021),y)))),min(y,pow(tan(max(mod(aud(max(x,0.85486794),max(0.84894824,x)),pow(0.38492107,0.7856226)),0.044297457)),y))))));
    float b = noi(tan(y),aud(aud(min(noi(min(aud(mod(x,max(x,tan(aud(0.5687175,x)))),x),0.89705443),tan(0.9097929)),0.92104506),pow(min(tan(sin(max(0.594342,cos(max(max(0.5248003,0.6158283),sin(0.399328)))))),min(y,y)),y)),aud(0.5440228,pow(mod(noi(noi(mod(min(noi(aud(y,0.93279696),max(0.28014016,x)),min(cos(x),mod(x,0.9169202))),tan(sin(pow(y,0.3055601)))),sin(cos(pow(0.2747798,cos(0.7637551))))),max(mod(x,max(min(min(x,0.6618109),cos(x)),tan(min(y,y)))),tan(aud(0.4669063,0.39192867)))),pow(mod(x,pow(tan(x),sin(0.79210496))),tan(pow(max(max(aud(0.8413367,0.9107723),0.06379914),x),0.17613006)))),min(x,pow(tan(max(mod(aud(max(y,0.73919845),max(0.043177128,0.49372745)),pow(0.34293604,0.10541153)),0.7037158)),0.9050038))))));
    return vec3(r, g, b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);
    gl_FragColor = vec4(RGB, 1.0);
}
