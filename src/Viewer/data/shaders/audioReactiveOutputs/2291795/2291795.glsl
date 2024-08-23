/* ############################
Evolved using software @ https://github.com/cdvetal/EvolvingInteractiveImages

// 2024 - 8 - 23

// Generation: 8
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
    float r = var(sin(sub(add(mul(add(aud(sin(cos(add(sin(div(y,y)),0.6946101))),var(var(x))),aud(0.2485714,y)),mul(sin(aud(pow(add(x,x),cos(sin(sub(x,x)))),0.8589835)),y)),tan(aud(x,aud(aud(div(add(pow(tan(x),tan(y)),mul(x,pow(y,x))),div(tan(add(x,y)),aud(tan(x),sub(0.42210364,y)))),mul(x,div(y,mul(sub(y,y),aud(0.20575428,x))))),tan(sub(aud(sin(aud(0.043804884,x)),pow(x,0.95324945)),pow(aud(y,y),cos(y)))))))),sub(mul(sub(add(aud(pow(x,x),0.1513629),x),mul(aud(var(div(add(sin(0.35503006),y),sub(pow(x,x),mul(x,x)))),y),pow(sub(x,0.8072977),tan(x)))),tan(add(sub(tan(var(cos(y))),0.5539706),sin(var(sub(var(0.406276),add(cos(x),div(y,0.77621174)))))))),mul(x,aud(sin(mul(mul(aud(sub(add(x,x),0.94245577),var(cos(0.39228916))),mul(var(x),y)),aud(tan(x),y))),sub(mul(sub(sin(div(div(y,x),pow(0.36595345,x))),pow(div(y,aud(0.28419995,0.5614219)),div(var(y),sin(x)))),sin(tan(sin(0.6254194)))),div(sin(sub(pow(div(x,0.15432954),0.1104362),add(sin(y),pow(x,y)))),x))))))));
    float g = var(sin(sub(add(mul(add(aud(sin(cos(add(sin(div(x,y)),x))),var(var(1.0))),aud(x,x)),mul(sin(aud(pow(add(0.41779613,0.07964373),cos(sin(sub(x,x)))),y)),x)),tan(aud(0.06704855,aud(aud(div(add(pow(tan(y),tan(y)),mul(y,pow(y,x))),div(tan(add(0.9216702,0.6201482)),aud(tan(0.67860293),sub(x,0.57367516)))),mul(x,div(0.9187176,mul(sub(0.8496473,0.17093182),aud(0.77404,0.121626854))))),tan(sub(aud(sin(aud(y,y)),pow(x,0.6893866)),pow(aud(x,y),cos(y)))))))),sub(mul(sub(add(aud(pow(0.12300491,y),y),x),mul(aud(var(div(add(sin(0.5858722),y),sub(pow(y,x),mul(0.07868981,y)))),0.30001235),pow(sub(y,y),tan(x)))),tan(add(sub(tan(var(cos(x))),0.7011509),sin(var(sub(var(x),add(cos(y),div(0.03378725,y)))))))),mul(x,aud(sin(mul(mul(aud(sub(add(x,y),x),var(cos(x))),mul(var(0.68705034),y)),aud(tan(x),0.6316724))),sub(mul(sub(sin(div(div(0.24280453,0.36707425),pow(y,x))),pow(div(y,aud(y,0.11436868)),div(var(y),sin(y)))),sin(tan(sin(x)))),div(sin(sub(pow(div(0.7471559,y),x),add(sin(0.17040539),pow(x,0.6819992)))),y))))))));
    float b = var(sin(sub(add(mul(add(aud(sin(cos(add(sin(div(x,y)),y))),var(var(x))),aud(y,0.5352626)),mul(sin(aud(pow(add(0.6815467,y),cos(sin(sub(x,x)))),x)),0.96056867)),tan(aud(y,aud(aud(div(add(pow(tan(0.8267784),tan(y)),mul(0.39167547,pow(y,y))),div(tan(add(0.47900653,0.7951038)),aud(tan(x),sub(y,0.4811027)))),mul(x,div(0.58290744,mul(sub(0.93316984,y),aud(x,0.069497585))))),tan(sub(aud(sin(aud(y,0.93988657)),pow(0.7404103,x)),pow(aud(y,x),cos(x)))))))),sub(mul(sub(add(aud(pow(y,y),y),x),mul(aud(var(div(add(sin(y),y),sub(pow(x,x),mul(0.46232057,0.25176907)))),0.3446219),pow(sub(x,0.5967307),tan(x)))),tan(add(sub(tan(var(cos(x))),y),sin(var(sub(var(y),add(cos(y),div(y,y)))))))),mul(y,aud(sin(mul(mul(aud(sub(add(0.48005724,x),y),var(cos(y))),mul(var(0.8087268),x)),aud(tan(y),x))),sub(mul(sub(sin(div(div(0.041553974,0.30349398),pow(x,0.6282668))),pow(div(y,aud(0.18708849,0.018230915)),div(var(0.34354806),sin(0.8277502)))),sin(tan(sin(x)))),div(sin(sub(pow(div(0.7194874,y),y),add(sin(x),pow(0.98818207,0.19727182)))),0.7791419))))))));
    return vec3(r, g, b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);
    gl_FragColor = vec4(RGB, 1.0);
}
