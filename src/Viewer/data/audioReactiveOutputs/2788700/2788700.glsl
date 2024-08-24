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
    float r = sub(mul(sub(sub(x,sin(tan(y))),y),pow(div(aud(x,div(mul(pow(sin(div(div(y,x),y)),sub(tan(y),div(cos(x),y))),tan(y)),sub(pow(cos(cos(0.8659959)),tan(cos(mul(0.44553995,x)))),cos(sin(x))))),add(mul(mul(aud(0.3936057,add(aud(tan(y),cos(y)),sub(y,add(x,y)))),mul(0.44057512,sin(x))),sub(sub(mul(mul(cos(y),aud(x,0.29541993)),sub(mul(0.03834963,0.19229078),0.13279629)),sub(aud(cos(0.16697383),cos(x)),0.670846)),cos(cos(aud(0.63703084,pow(0.3210559,x)))))),add(add(div(add(sub(y,mul(0.6987791,y)),sub(sub(x,x),cos(y))),x),sub(sub(tan(0.7297559),x),mul(tan(sub(x,x)),y))),0.0017592907))),pow(mul(y,div(sin(div(pow(mul(div(0.8550267,y),mul(x,0.17521572)),div(cos(y),aud(0.13393164,x))),sub(cos(pow(x,0.9006007)),pow(mul(x,0.7077849),aud(0.23247266,y))))),cos(mul(tan(mul(tan(0.7446258),sin(0.56600547))),0.96475816)))),sub(y,0.609838)))),div(sub(aud(div(0.53789735,x),sin(pow(sin(mul(pow(aud(cos(0.2110734),0.500648),y),0.5874729)),add(sub(y,y),div(tan(0.75640726),cos(tan(aud(y,y)))))))),mul(0.8823948,cos(add(add(x,x),add(0.24623156,sin(tan(sin(0.13311839)))))))),sub(sin(add(mul(y,div(sin(x),pow(div(pow(0.8977194,tan(y)),mul(pow(y,x),div(x,y))),sin(add(add(0.9689956,0.5911577),div(x,x)))))),sin(sub(tan(mul(sub(tan(0.9027729),aud(y,0.8673868)),tan(cos(x)))),sub(x,cos(mul(cos(0.4660697),y))))))),cos(pow(cos(sub(tan(tan(y)),cos(y))),y)))));
    float g = sub(mul(sub(sub(0.24101329,sin(tan(y))),y),pow(div(aud(y,div(mul(pow(sin(div(div(y,0.17403483),0.7593243)),sub(tan(x),div(cos(0.14998388),x))),tan(0.66555977)),sub(pow(cos(cos(x)),tan(cos(mul(0.763505,x)))),cos(sin(y))))),add(mul(mul(aud(x,add(aud(tan(x),cos(0.31010008)),sub(x,add(y,0.43220377)))),mul(x,sin(0.12075734))),sub(sub(mul(mul(cos(y),aud(0.0236094,y)),sub(mul(y,x),0.86869526)),sub(aud(cos(x),cos(0.0987947)),y)),cos(cos(aud(y,pow(x,0.32299995)))))),add(add(div(add(sub(0.015004635,mul(0.85562754,0.24113417)),sub(sub(0.5217681,y),cos(y))),0.85718584),sub(sub(tan(0.88765883),0.59876156),mul(tan(sub(x,x)),x))),y))),pow(mul(x,div(sin(div(pow(mul(div(y,0.051335573),mul(x,0.9599347)),div(cos(0.55209374),aud(x,0.06145096))),sub(cos(pow(x,x)),pow(mul(0.61957216,y),aud(0.46731353,0.41656327))))),cos(mul(tan(mul(tan(0.87532735),sin(y))),x)))),sub(x,y)))),div(sub(aud(div(0.9301784,y),sin(pow(sin(mul(pow(aud(cos(0.94926953),0.28447437),x),0.62467456)),add(sub(y,y),div(tan(0.48775053),cos(tan(aud(x,0.1627419)))))))),mul(y,cos(add(add(y,y),add(x,sin(tan(sin(x)))))))),sub(sin(add(mul(x,div(sin(0.37457561),pow(div(pow(x,tan(0.70929193)),mul(pow(x,0.9426458),div(0.6367128,y))),sin(add(add(y,y),div(0.86483717,x)))))),sin(sub(tan(mul(sub(tan(0.33761668),aud(x,0.6939788)),tan(cos(x)))),sub(0.16391039,cos(mul(cos(0.6371751),0.08929515))))))),cos(pow(cos(sub(tan(tan(x)),cos(0.35891867))),0.34178114)))));
    float b = sub(mul(sub(sub(0.84759736,sin(tan(x))),x),pow(div(aud(y,div(mul(pow(sin(div(div(0.68640447,x),x)),sub(tan(0.65168667),div(cos(y),x))),tan(x)),sub(pow(cos(cos(0.02276516)),tan(cos(mul(x,y)))),cos(sin(y))))),add(mul(mul(aud(0.48059106,add(aud(tan(x),cos(0.8478818)),sub(x,add(0.8461311,0.4068563)))),mul(0.10248184,sin(0.030512333))),sub(sub(mul(mul(cos(x),aud(x,y)),sub(mul(y,x),x)),sub(aud(cos(x),cos(0.9380603)),0.032401323)),cos(cos(aud(x,pow(y,0.16789532)))))),add(add(div(add(sub(0.7421584,mul(x,0.63991237)),sub(sub(y,0.31117773),cos(y))),y),sub(sub(tan(0.3476658),y),mul(tan(sub(0.1831038,y)),0.05214548))),x))),pow(mul(0.86610746,div(sin(div(pow(mul(div(0.16850042,y),mul(0.25967598,y)),div(cos(y),aud(x,x))),sub(cos(pow(y,0.9645629)),pow(mul(x,0.27710176),aud(0.013501644,x))))),cos(mul(tan(mul(tan(x),sin(0.723907))),x)))),sub(y,0.70575476)))),div(sub(aud(div(0.83828735,x),sin(pow(sin(mul(pow(aud(cos(0.5759506),y),y),y)),add(sub(0.6548543,x),div(tan(y),cos(tan(aud(0.13915229,0.64514565)))))))),mul(x,cos(add(add(0.8934562,y),add(0.37689543,sin(tan(sin(0.20599532)))))))),sub(sin(add(mul(y,div(sin(y),pow(div(pow(x,tan(x)),mul(pow(x,x),div(y,x))),sin(add(add(y,y),div(x,0.15009284)))))),sin(sub(tan(mul(sub(tan(0.49899793),aud(y,y)),tan(cos(x)))),sub(x,cos(mul(cos(x),x))))))),cos(pow(cos(sub(tan(tan(y)),cos(0.1827178))),0.42984176)))));
    return vec3(r, g, b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);
    gl_FragColor = vec4(RGB, 1.0);
}
