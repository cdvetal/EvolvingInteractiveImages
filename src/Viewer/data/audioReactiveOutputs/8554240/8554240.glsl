/* ############################
Evolved using software @ https://github.com/cdvetal/EvolvingInteractiveImages

// 2024 - 8 - 23

// Generation: 1
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
    float r = add(0.1972065,max(tan(aud(aud(div(mul(x,aud(0.09763932,aud(x,sin(y)))),cos(add(aud(bri(x,0.65657496),aud(bri(sub(0.90225935,y),y),aud(y,aud(0.53087306,0.3221693)))),min(bri(x,bri(max(0.91158915,x),0.44339037)),sub(bri(y,max(y,x)),mul(y,add(x,y))))))),min(sin(pow(div(max(x,max(max(y,0.34752345),mul(0.5484848,0.43190718))),0.87152624),cos(aud(y,sub(div(0.73613095,0.75152683),mul(y,x)))))),y)),sin(min(tan(min(min(cos(div(pow(0.18687439,x),pow(0.5907748,0.7657974))),mul(sin(y),cos(max(y,0.8211143)))),0.6227076)),max(bri(x,sin(max(add(add(x,x),max(x,0.71448183)),sub(x,0.9309001)))),0.57027435))))),pow(sub(bri(sub(bri(add(y,div(add(y,sin(bri(0.087937355,y))),min(add(aud(y,x),min(x,x)),add(mul(x,x),y)))),aud(x,sub(div(bri(0.022628546,x),bri(min(x,0.01941657),aud(0.4503739,x))),pow(bri(y,y),x)))),y),pow(max(pow(bri(sub(div(max(0.76337385,0.71507955),sin(0.7682924)),min(add(x,0.9825113),sin(y))),pow(pow(max(y,y),y),min(bri(0.66485786,x),x))),pow(div(mul(add(x,x),tan(x)),add(sin(0.62101936),cos(0.8219218))),add(0.8116503,bri(min(0.7522347,x),x)))),max(cos(div(min(cos(x),0.0053732395),div(y,max(y,y)))),y)),sin(div(cos(y),pow(x,y))))),x),tan(aud(0.94411945,max(pow(y,aud(add(x,0.29078126),x)),pow(pow(mul(sin(bri(tan(y),y)),0.9423919),sin(max(sin(mul(x,x)),mul(aud(0.74926114,0.49178624),tan(x))))),bri(add(y,aud(y,sub(pow(0.83136487,0.72203636),sin(y)))),y))))))));
    float g = add(x,max(tan(aud(aud(div(mul(x,aud(x,aud(x,sin(0.41147685)))),cos(add(aud(bri(y,x),aud(bri(sub(y,x),y),aud(x,aud(y,x)))),min(bri(y,bri(max(y,y),y)),sub(bri(x,max(0.7637944,y)),mul(x,add(y,y))))))),min(sin(pow(div(max(0.06906867,max(max(0.20112419,0.79800916),mul(x,x))),y),cos(aud(x,sub(div(x,0.14502692),mul(0.80909204,x)))))),x)),sin(min(tan(min(min(cos(div(pow(0.51141024,y),pow(x,0.13865662))),mul(sin(y),cos(max(x,0.4292283)))),x)),max(bri(y,sin(max(add(add(x,x),max(y,x)),sub(x,0.47764254)))),x))))),pow(sub(bri(sub(bri(add(y,div(add(y,sin(bri(0.10133314,y))),min(add(aud(x,y),min(0.9422159,x)),add(mul(y,x),x)))),aud(0.81641626,sub(div(bri(x,y),bri(min(0.99377966,y),aud(x,x))),pow(bri(x,0.45597887),y)))),x),pow(max(pow(bri(sub(div(max(y,y),sin(x)),min(add(0.40713406,y),sin(x))),pow(pow(max(0.9839213,y),y),min(bri(0.57088184,0.2985618),0.14878464))),pow(div(mul(add(x,y),tan(x)),add(sin(x),cos(0.4021201))),add(x,bri(min(y,y),y)))),max(cos(div(min(cos(x),0.07531953),div(y,max(x,0.9984865)))),0.88068724)),sin(div(cos(x),pow(y,x))))),y),tan(aud(x,max(pow(0.97652197,aud(add(y,0.9023683),x)),pow(pow(mul(sin(bri(tan(0.30331755),x)),0.9150357),sin(max(sin(mul(x,y)),mul(aud(0.5709317,0.95986915),tan(0.070047855))))),bri(add(0.42755294,aud(y,sub(pow(x,0.8827944),sin(0.06788564)))),x))))))));
    float b = add(x,max(tan(aud(aud(div(mul(y,aud(y,aud(y,sin(0.4696808)))),cos(add(aud(bri(0.5579624,x),aud(bri(sub(0.019106388,x),y),aud(y,aud(x,0.8127885)))),min(bri(x,bri(max(x,0.48663712),0.5840025)),sub(bri(y,max(y,y)),mul(0.08818698,add(x,y))))))),min(sin(pow(div(max(y,max(max(0.6776154,y),mul(0.2702291,x))),y),cos(aud(x,sub(div(y,y),mul(y,y)))))),x)),sin(min(tan(min(min(cos(div(pow(0.66105366,y),pow(0.57943606,x))),mul(sin(x),cos(max(y,y)))),0.44175267)),max(bri(x,sin(max(add(add(y,y),max(y,0.53096914)),sub(0.8426342,0.13612652)))),y))))),pow(sub(bri(sub(bri(add(x,div(add(x,sin(bri(0.53465414,0.31888676))),min(add(aud(x,x),min(0.06750035,0.8342066)),add(mul(x,x),x)))),aud(x,sub(div(bri(x,0.009677887),bri(min(x,0.8781004),aud(0.09421611,y))),pow(bri(0.68884563,x),0.5346174)))),0.78033876),pow(max(pow(bri(sub(div(max(0.5755749,0.1627512),sin(0.45763826)),min(add(0.69245934,0.89180255),sin(0.72299385))),pow(pow(max(y,0.2852037),x),min(bri(y,0.679281),0.83061504))),pow(div(mul(add(y,x),tan(0.116849184)),add(sin(0.74467945),cos(0.8640883))),add(0.032678127,bri(min(y,y),x)))),max(cos(div(min(cos(x),x),div(x,max(x,0.67528486)))),y)),sin(div(cos(0.46178675),pow(y,x))))),y),tan(aud(x,max(pow(0.9435818,aud(add(0.4153459,0.364609),0.9912915)),pow(pow(mul(sin(bri(tan(0.26474285),x)),0.16450787),sin(max(sin(mul(x,0.2037034)),mul(aud(y,0.13081884),tan(y))))),bri(add(x,aud(y,sub(pow(x,x),sin(y)))),y))))))));
    return vec3(r, g, b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);
    gl_FragColor = vec4(RGB, 1.0);
}
