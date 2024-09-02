/* ############################
Evolved using software @ https://github.com/cdvetal/EvolvingInteractiveImages





############################ */

in vec4 gl_FragCoord;

in vec2 uv;
uniform sampler2D image;
uniform float externalVal;
uniform int nVariables;
uniform float variables[10];
uniform float audioSpectrum[512];

const float EPSILON = 1e-10;

//conversions from https://www.shadertoy.com/view/4dKcWK
vec3 RGBtoHCV(vec3 rgb)
{
    vec4 p = (rgb.g < rgb.b) ? vec4(rgb.bg, -1., 2. / 3.) : vec4(rgb.gb, 0., -1. / 3.);
    vec4 q = (rgb.r < p.x) ? vec4(p.xyw, rgb.r) : vec4(rgb.r, p.yzx);
    float c = q.x - min(q.w, q.y);
    float h = abs((q.w - q.y) / (6. * c + EPSILON) + q.z);
    return vec3(h, c, q.x);
}

vec3 RGBtoHSV(vec3 rgb)
{
    // RGB [0..1] to Hue-Saturation-Value [0..1]
    vec3 hcv = RGBtoHCV(rgb);
    float s = hcv.y / (hcv.z + EPSILON);
    return vec3(hcv.x, s, hcv.z);
}

vec3 HUEtoRGB(float hue)
{
    vec3 rgb = abs(hue * 6. - vec3(3, 2, 4)) * vec3(1, -1, -1) + vec3(-1, 2, 2);
    return clamp(rgb, 0., 1.);
}

vec3 HSVtoRGB(vec3 hsv)
{
    // Hue-Saturation-Value [0..1] to RGB [0..1]
    vec3 rgb = HUEtoRGB(hsv.x);
    return ((rgb - 1.) * hsv.y + 1.) * hsv.z;
}


float hash(float p) { p = fract(p * 0.011); p *= p + 7.5; p *= p + p; return fract(p); }
float hash(vec2 p) {vec3 p3 = fract(vec3(p.xyx) * 0.13); p3 += dot(p3, p3.yzx + 3.333); return fract((p3.x + p3.y) * p3.z); }

//noise from https://www.shadertoy.com/view/4dS3Wd
float noi(float x) {
    float i = floor(x);
    float f = fract(x);
    float u = f * f * (3.0 - 2.0 * f);
    return mix(hash(i), hash(i + 1.0), u);
}

float noi(float x, float y) {
    vec2 inVec = vec2(x,y);
    vec2 i = floor(inVec);
    vec2 f = fract(inVec);

	float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

//audio
float aud(float x, float y){
    float center = x * audioSpectrum.length;
    float radius = (y * audioSpectrum.length) / 2;
    int minIndex = int(max(center - radius, 0));
    int maxIndex = int(min(center + radius, audioSpectrum.length));

    float sum = 0;

    for(int i = minIndex; i < maxIndex; i++){
        sum += audioSpectrum[i];
    }

    return sum/(radius/2); //sum/(radius * 2)
}

//like aud but low sounds - first half of spectrum used
float aul(float x, float y){
    float usedLength = audioSpectrum.length / 2;
    float center = x * usedLength;
    float radius = (y * usedLength) / 2;
    int minIndex = int(max(center - radius, 0));
    int maxIndex = int(min(center + radius, usedLength));

    float sum = 0;

    for(int i = minIndex; i < maxIndex; i++){
        sum += audioSpectrum[i];
    }

    return sum/(radius/2);
}

//like aud but high sounds - second half of spectrum used
float auh(float x, float y){
    float usedLength = audioSpectrum.length / 2;
    float center = x * usedLength + usedLength;
    float radius = (y * usedLength) / 2 + usedLength;
    int minIndex = int(max(center - radius, usedLength));
    int maxIndex = int(min(center + radius, audioSpectrum.length));

    float sum = 0;

    for(int i = minIndex; i < maxIndex; i++){
        sum += audioSpectrum[i];
    }

    return sum/(radius/2);
}

float bri(float x, float y){ //brightness https://stackoverflow.com/questions/596216/formula-to-determine-perceived-brightness-of-rgb-color
    float xFloor = floor(x);
    float yFloor = floor(y);

    float xRemainder = x - xFloor;
    float yRemainder = y - yFloor;

    if (int(xFloor) % 2 != 0) x = 1 - xRemainder; 
    if (int(yFloor) % 2 != 0) y = 1 - yRemainder; 
    
    vec2 uv = vec2(x,y);
    vec3 rgb = texture(image, uv).rgb;

    float brightness = (0.2126*rgb.r + 0.7152*rgb.g + 0.0722*rgb.b);
    return brightness;
}

float var(float x){
    int varIndex = int(round(x * nVariables));

    if(varIndex >= nVariables){
        varIndex = nVariables - 1;
    }

    return variables[varIndex];
}

float add(float a, float b){
    return a + b;
}

float sub(float a, float b){
    return a - b;
}

float mul(float a, float b){
    return a * b;
}

float div(float a, float b){
    return a / b;
}

vec3 generateRGB(float x, float y){
    float r = bri(x,mul(y,div(bri(sub(div(aud(bri(sin(add(aud(x,bri(sin(div(0.04187584,y)),tan(cos(x)))),div(sub(sin(min(x,0.38397098)),min(pow(x,0.8038292),bri(y,y))),aud(x,aud(bri(y,x),y))))),pow(sin(0.32789135),y)),pow(sub(aud(0.18000579,aud(tan(x),min(cos(x),div(max(x,0.16079068),x)))),max(add(sin(sub(div(x,y),bri(0.4217074,0.30079865))),sin(min(pow(y,y),min(0.35249877,x)))),x)),bri(x,0.32972288))),max(y,div(cos(sin(max(min(x,bri(aud(0.6103668,x),y)),aud(cos(0.5737374),bri(pow(x,y),y))))),x))),div(aud(0.022175789,0.41469312),mul(sub(y,max(mul(aud(0.79189324,x),0.34645128),0.5674596)),add(0.031748056,sub(min(sub(div(bri(tan(x),cos(x)),y),x),min(div(x,aud(min(y,x),tan(x))),0.03826189)),cos(0.31106973)))))),sin(div(max(max(bri(min(div(aud(aud(tan(y),tan(0.8169799)),pow(tan(0.34961534),div(y,x))),0.1412549),pow(div(sub(sin(y),0.49693298),x),add(x,sin(min(y,0.5480137))))),pow(bri(x,x),bri(0.5293782,tan(x)))),mul(bri(pow(bri(tan(aud(x,0.3732562)),y),aud(div(bri(0.6090181,y),sub(0.87415814,x)),bri(div(0.64893293,x),pow(y,x)))),aud(max(bri(cos(y),mul(0.7222998,x)),tan(tan(x))),y)),x)),x),add(cos(sub(sin(aud(aud(mul(add(0.628108,0.59678507),aud(0.97144413,x)),min(max(y,x),sin(0.39656186))),min(sub(x,cos(x)),div(y,pow(0.5061312,0.66999197))))),mul(y,bri(aud(sub(0.63356805,0.1110909),div(aud(x,x),sub(y,y))),mul(aud(bri(0.6108515,y),mul(x,x)),bri(sub(0.5652709,y),aud(y,0.60948515))))))),div(y,bri(cos(aud(min(div(add(x,y),bri(0.57767224,0.59350324)),max(x,mul(y,0.022131681))),bri(bri(min(y,y),tan(0.18816137)),bri(tan(y),min(y,y))))),max(add(min(aud(sin(y),add(x,y)),bri(max(x,y),max(0.49045253,0.6498375))),cos(aud(aud(0.76716375,y),bri(x,0.022208214)))),max(y,0.9164498)))))))),cos(cos(0.6398883)))));
    float g = bri(0.21200919,mul(0.31311512,div(bri(sub(div(aud(bri(sin(add(aud(0.31714487,bri(sin(div(x,y)),tan(cos(y)))),div(sub(sin(min(y,x)),min(pow(x,x),bri(y,y))),aud(x,aud(bri(0.41042066,y),0.5172367))))),pow(sin(x),0.5039599)),pow(sub(aud(y,aud(tan(y),min(cos(y),div(max(y,y),x)))),max(add(sin(sub(div(x,x),bri(0.5081427,y))),sin(min(pow(y,x),min(y,0.20449781)))),x)),bri(0.09860945,0.020729542))),max(y,div(cos(sin(max(min(x,bri(aud(0.6615138,x),x)),aud(cos(y),bri(pow(y,x),x))))),0.025414467))),div(aud(y,y),mul(sub(0.14961982,max(mul(aud(x,x),y),0.37310338)),add(y,sub(min(sub(div(bri(tan(y),cos(x)),0.055416584),x),min(div(y,aud(min(0.8872323,x),tan(y))),y)),cos(x)))))),sin(div(max(max(bri(min(div(aud(aud(tan(0.550282),tan(y)),pow(tan(y),div(x,x))),x),pow(div(sub(sin(x),0.9836147),x),add(0.6633558,sin(min(0.8650484,y))))),pow(bri(y,0.34358),bri(y,tan(0.88437104)))),mul(bri(pow(bri(tan(aud(0.105523586,0.600832)),0.19354081),aud(div(bri(0.0015513897,x),sub(y,x)),bri(div(0.5837846,x),pow(0.34904194,y)))),aud(max(bri(cos(x),mul(x,0.29025865)),tan(tan(0.08800006))),0.921257)),0.62997484)),0.42070222),add(cos(sub(sin(aud(aud(mul(add(x,0.44694757),aud(y,x)),min(max(y,y),sin(0.77104855))),min(sub(y,cos(0.47847366)),div(0.8174093,pow(0.627579,x))))),mul(y,bri(aud(sub(0.9888494,y),div(aud(0.5132022,0.25967717),sub(x,x))),mul(aud(bri(y,0.5247731),mul(y,0.86119175)),bri(sub(x,x),aud(x,y))))))),div(0.3409953,bri(cos(aud(min(div(add(0.23419333,0.99360704),bri(y,y)),max(y,mul(y,y))),bri(bri(min(y,y),tan(y)),bri(tan(0.19795918),min(y,0.8773806))))),max(add(min(aud(sin(0.47908235),add(x,x)),bri(max(0.25748444,x),max(y,x))),cos(aud(aud(y,y),bri(x,y)))),max(0.04583907,y)))))))),cos(cos(0.939857)))));
    float b = bri(x,mul(0.48066235,div(bri(sub(div(aud(bri(sin(add(aud(y,bri(sin(div(x,0.4664719)),tan(cos(y)))),div(sub(sin(min(y,0.31501532)),min(pow(x,0.6868665),bri(0.43116522,0.6776521))),aud(0.41152096,aud(bri(y,y),0.052761793))))),pow(sin(x),y)),pow(sub(aud(x,aud(tan(0.022508621),min(cos(0.25016212),div(max(0.39446163,0.6266146),x)))),max(add(sin(sub(div(x,0.029076815),bri(y,y))),sin(min(pow(0.6660657,y),min(0.5383463,y)))),x)),bri(0.54467154,x))),max(0.92411804,div(cos(sin(max(min(x,bri(aud(x,y),x)),aud(cos(x),bri(pow(y,y),y))))),0.08012748))),div(aud(0.67403126,y),mul(sub(x,max(mul(aud(y,x),0.47932553),0.7356949)),add(y,sub(min(sub(div(bri(tan(x),cos(y)),x),y),min(div(x,aud(min(y,0.65210986),tan(0.7121067))),x)),cos(0.28345037)))))),sin(div(max(max(bri(min(div(aud(aud(tan(0.6603098),tan(x)),pow(tan(0.23349047),div(y,0.7972398))),0.8672669),pow(div(sub(sin(y),y),y),add(y,sin(min(x,y))))),pow(bri(y,y),bri(y,tan(0.17657304)))),mul(bri(pow(bri(tan(aud(x,0.12034845)),y),aud(div(bri(y,x),sub(y,0.33055973)),bri(div(0.5525751,x),pow(0.28580236,y)))),aud(max(bri(cos(0.304075),mul(0.16958547,x)),tan(tan(x))),x)),x)),x),add(cos(sub(sin(aud(aud(mul(add(0.63830256,y),aud(y,y)),min(max(0.74724627,y),sin(y))),min(sub(x,cos(x)),div(x,pow(x,y))))),mul(x,bri(aud(sub(y,x),div(aud(x,0.46297932),sub(0.377594,y))),mul(aud(bri(y,x),mul(0.20051813,0.14230204)),bri(sub(x,y),aud(y,0.3392701))))))),div(0.5108969,bri(cos(aud(min(div(add(y,x),bri(x,x)),max(y,mul(x,y))),bri(bri(min(0.5969448,y),tan(x)),bri(tan(0.44875288),min(x,x))))),max(add(min(aud(sin(0.69514513),add(y,x)),bri(max(y,x),max(y,0.0035421848))),cos(aud(aud(y,y),bri(x,x)))),max(0.05610943,y)))))))),cos(cos(y)))));
    return vec3(r,g,b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);

    gl_FragColor = vec4(RGB.x, RGB.y, RGB.z, 1.0);
}
