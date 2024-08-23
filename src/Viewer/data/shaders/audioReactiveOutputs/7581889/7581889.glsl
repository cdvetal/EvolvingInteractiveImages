/* ############################
Evolved using software @ https://github.com/cdvetal/EvolvingInteractiveImages

// 2024 - 8 - 23

// Generation: 4
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
    float r = sub(mul(sub(sub(x,sin(tan(y))),y),aud(div(tan(x),add(mul(mul(aud(0.41070414,sub(aud(tan(y),cos(y)),sub(y,add(x,y)))),div(0.6661887,sin(x))),sub(sub(mul(mul(cos(y),aud(x,0.29541993)),sub(mul(0.21426511,0.19229078),0.13279629)),mul(aud(cos(0.16697383),cos(y)),0.5539229)),sin(cos(aud(0.63703084,pow(0.3210559,x)))))),add(add(div(sub(sub(y,mul(0.6987791,y)),sub(sub(x,x),sin(x))),x),mul(sub(aud(0.7297559,0.15375447),x),mul(tan(sub(x,x)),y))),0.0017592907))),pow(mul(y,div(div(div(pow(mul(sin(0.8550267),mul(x,0.17521572)),sin(cos(y))),add(cos(aud(x,0.9006007)),pow(mul(x,0.7077849),tan(0.23247266)))),0.35701585),cos(mul(tan(sub(tan(0.7446258),sin(0.56600547))),0.8109832)))),sub(y,0.609838)))),div(sub(aud(div(0.53789735,x),sin(pow(sin(mul(pow(aud(cos(0.2110734),0.500648),y),0.5874729)),add(add(y,y),div(tan(0.75640726),cos(tan(tan(y)))))))),sub(0.8823948,sin(add(add(x,x),add(0.24623156,sin(aud(sin(0.34767413),0.6030762))))))),sub(sin(add(mul(y,div(sin(x),pow(div(pow(0.8977194,tan(y)),div(aud(y,x),div(x,y))),sin(add(add(0.9689956,0.5911577),div(x,x)))))),div(sub(tan(mul(sub(cos(0.9027729),aud(y,1.0)),tan(cos(x)))),mul(y,cos(mul(cos(0.4660697),y)))),0.24234915))),cos(pow(cos(mul(tan(tan(y)),sin(y))),y)))));
    float g = sub(mul(sub(sub(0.24101329,sin(tan(y))),y),aud(div(tan(y),add(mul(mul(aud(x,sub(aud(tan(x),cos(0.31010008)),sub(x,add(y,0.5816126)))),div(x,sin(0.12075734))),sub(sub(mul(mul(cos(y),aud(0.0236094,y)),sub(mul(y,x),0.6157403)),mul(aud(cos(x),cos(y)),y)),sin(cos(aud(y,pow(x,0.32299995)))))),add(add(div(sub(sub(0.100528955,mul(0.99244523,0.24113417)),sub(sub(0.5217681,0.101931095),sin(y))),0.85718584),mul(sub(aud(0.9475622,y),0.60994387),mul(tan(sub(x,x)),x))),y))),pow(mul(x,div(div(div(pow(mul(sin(y),mul(x,0.9599347)),sin(cos(0.55209374))),add(cos(aud(x,x)),pow(mul(0.61957216,y),tan(0.46731353)))),y),cos(mul(tan(sub(tan(0.87532735),sin(y))),x)))),sub(x,y)))),div(sub(aud(div(0.9301784,y),sin(pow(sin(mul(pow(aud(cos(0.94926953),0.28447437),x),0.62467456)),add(add(y,y),div(tan(0.48775053),cos(tan(tan(x)))))))),sub(y,sin(add(add(y,y),add(x,sin(aud(sin(x),y))))))),sub(sin(add(mul(x,div(sin(0.37457561),pow(div(pow(x,tan(0.70929193)),div(aud(x,0.9426458),div(0.6367128,y))),sin(add(add(0.11604524,y),div(0.86483717,x)))))),div(sub(tan(mul(sub(cos(0.33761668),aud(x,0.6939788)),tan(cos(x)))),mul(0.20279312,cos(mul(cos(0.40266085),0.06587982)))),0.0435524))),cos(pow(cos(mul(tan(tan(x)),sin(y))),0.34178114)))));
    float b = sub(mul(sub(sub(0.84759736,sin(tan(y))),x),aud(div(tan(y),add(mul(mul(aud(0.48059106,sub(aud(tan(x),cos(0.8478818)),sub(x,add(0.9407892,0.2141738)))),div(0.25141335,sin(0.030512333))),sub(sub(mul(mul(cos(x),aud(x,y)),sub(mul(y,x),x)),mul(aud(cos(x),cos(0.8982153)),y)),sin(cos(aud(x,pow(y,0.16789532)))))),add(add(div(sub(sub(0.68763256,mul(x,0.63991237)),sub(sub(y,0.045284033),sin(y))),y),mul(sub(aud(0.3476658,y),y),mul(tan(sub(0.1831038,y)),0.05214548))),x))),pow(mul(0.86610746,div(div(div(pow(mul(sin(0.16850042),mul(0.25967598,y)),sin(cos(y))),add(cos(aud(y,0.9645629)),pow(mul(x,0.27710176),tan(0.013501644)))),0.94375086),cos(mul(tan(sub(tan(x),sin(0.723907))),x)))),sub(y,0.92043257)))),div(sub(aud(div(0.83828735,x),sin(pow(sin(mul(pow(aud(cos(0.5759506),y),y),y)),add(add(0.6548543,x),div(tan(y),cos(tan(tan(0.13915229)))))))),sub(x,sin(add(add(1.0,y),add(0.30786443,sin(aud(sin(0.20599532),y))))))),sub(sin(add(mul(y,div(sin(y),pow(div(pow(x,tan(x)),div(aud(x,x),div(y,x))),sin(add(add(y,y),div(x,0.15009284)))))),div(sub(tan(mul(sub(cos(0.49899793),aud(y,y)),tan(cos(x)))),mul(x,cos(mul(cos(x),x)))),x))),cos(pow(cos(mul(tan(tan(y)),sin(x))),0.42984176)))));
    return vec3(r, g, b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);
    gl_FragColor = vec4(RGB, 1.0);
}
