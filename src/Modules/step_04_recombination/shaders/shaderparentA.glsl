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
    float r = add(bri(div(cos(max(bri(aud(bri(x,bri(x,sin(mul(0.4298792,x)))),add(0.023480892,tan(y))),x),min(mul(pow(aud(pow(0.9692576,x),tan(aud(mul(0.81118727,sin(bri(bri(x,y),x))),add(y,bri(aud(y,pow(x,x)),sin(pow(y,y))))))),add(add(cos(tan(x)),div(sin(pow(y,bri(x,div(y,0.025997877)))),mul(bri(sub(sin(0.28882718),max(y,x)),min(sub(0.7500746,0.4926014),add(y,y))),x))),mul(sin(0.9444468),y))),y),bri(0.5061772,y)))),bri(aud(0.73836565,sin(tan(tan(y)))),pow(tan(pow(x,0.5691688)),min(x,x)))),bri(div(cos(aud(min(x,sub(cos(y),sin(aud(max(add(aud(cos(pow(0.5004759,x)),sin(0.43555236)),add(max(max(x,y),aud(0.107638836,x)),mul(max(x,x),bri(y,y)))),cos(x)),0.7098453)))),y)),tan(aud(bri(aud(y,mul(aud(sin(div(y,y)),x),0.41216993)),bri(add(x,y),max(y,pow(0.5463128,y)))),add(x,aud(pow(y,max(mul(aud(div(x,bri(y,0.91746426)),aud(bri(pow(x,y),aud(x,x)),0.83081865)),max(sin(y),0.40241838)),x)),0.8311014))))),bri(bri(x,div(mul(max(add(y,tan(div(0.98920155,bri(div(x,div(bri(x,y),pow(0.35752988,0.61543345))),add(sub(pow(x,y),pow(0.059648514,0.6648965)),pow(y,aud(y,0.713866))))))),sin(mul(y,0.83379364))),x),aud(0.18365145,y))),sub(0.32923746,x)))),bri(pow(cos(bri(add(0.726841,sub(sub(0.9234855,sub(tan(x),pow(aud(aud(div(aud(x,cos(x)),aud(aud(x,0.48058796),bri(x,0.93819785))),add(aud(y,mul(x,y)),bri(pow(x,0.8244467),add(0.25890684,0.38018703)))),sub(0.45722604,tan(x))),cos(x)))),add(min(bri(y,bri(x,0.17507148)),x),aud(mul(y,pow(aud(tan(aud(y,pow(y,0.10237193))),div(sub(0.17336154,min(x,x)),bri(min(0.07325125,x),y))),bri(max(0.63710284,aud(min(0.37436175,0.8431237),tan(x))),y))),bri(sub(add(x,y),div(div(sub(y,0.702564),aud(y,min(0.4917302,x))),pow(sub(cos(0.64080215),y),y))),aud(cos(pow(max(y,min(x,x)),bri(y,add(y,x)))),aud(y,pow(aud(bri(x,x),bri(0.56417274,x)),x)))))))),div(aud(div(mul(aud(max(mul(tan(sub(max(0.09414339,y),y)),x),pow(div(bri(add(0.4824047,x),pow(0.48161888,y)),0.77457523),add(min(y,sin(0.8456087)),add(cos(x),add(0.74043083,0.1070559))))),cos(add(sin(sub(mul(0.085864305,x),tan(y))),x))),min(x,aud(sub(sub(tan(x),sin(mul(0.63027215,x))),y),cos(aud(0.73991036,y))))),div(aud(bri(0.044650555,add(div(x,pow(div(0.6948204,x),0.4389243)),bri(tan(min(x,x)),0.5845227))),y),bri(x,y))),min(bri(pow(x,aud(max(bri(tan(sub(0.017204523,x)),bri(pow(0.43233275,y),cos(x))),bri(div(max(y,0.8334737),min(0.18871093,x)),add(min(x,x),pow(y,0.3620882)))),0.6276901)),y),aud(bri(aud(x,aud(div(y,min(0.7811103,y)),max(pow(cos(x),mul(y,y)),mul(pow(x,y),div(x,y))))),0.39966726),aud(x,div(sin(x),max(tan(0.6967368),y)))))),0.37984824))),y),aud(div(tan(max(x,aud(y,min(aud(y,sub(pow(sub(0.8711791,min(y,max(tan(y),y))),cos(bri(sub(mul(y,0.29395604),add(0.25155258,0.4822743)),pow(div(x,x),sub(0.94546366,y))))),x)),sub(x,0.2739377))))),bri(y,y)),min(0.3568523,bri(y,max(add(bri(x,0.5732002),pow(x,0.5750258)),bri(y,bri(0.5485594,div(pow(bri(cos(y),mul(max(bri(tan(x),y),aud(y,x)),add(add(min(0.3186202,y),pow(0.7013688,y)),bri(max(0.37011766,0.28682542),max(0.8490691,x))))),sub(y,bri(aud(sub(mul(x,x),pow(y,0.31015682)),y),mul(y,max(x,0.20506573))))),sub(pow(tan(mul(mul(sub(0.763551,0.43128014),bri(y,0.46292067)),cos(x))),0.7066469),div(mul(x,div(max(min(y,x),pow(x,0.25630808)),x)),y)))))))))));
    float g = add(bri(div(cos(max(bri(aud(bri(y,bri(y,sin(mul(y,x)))),add(y,tan(x))),0.6791253),min(mul(pow(aud(pow(y,x),tan(aud(mul(0.8012452,sin(bri(bri(x,x),0.10429335))),add(y,bri(aud(y,pow(y,0.9338598)),sin(pow(0.87101054,x))))))),add(add(cos(tan(y)),div(sin(pow(y,bri(y,div(y,y)))),mul(bri(sub(sin(0.61865234),max(0.4740131,y)),min(sub(x,0.8562515),add(x,y))),x))),mul(sin(0.14188576),y))),0.25262976),bri(x,x)))),bri(aud(x,sin(tan(tan(x)))),pow(tan(pow(x,y)),min(x,x)))),bri(div(cos(aud(min(y,sub(cos(x),sin(aud(max(add(aud(cos(pow(0.1339364,y)),sin(y)),add(max(max(y,0.14943933),aud(y,y)),mul(max(x,y),bri(0.81133103,y)))),cos(0.06163788)),y)))),0.9710493)),tan(aud(bri(aud(y,mul(aud(sin(div(0.6561289,y)),x),y)),bri(add(y,0.1543765),max(x,pow(x,y)))),add(y,aud(pow(x,max(mul(aud(div(y,bri(y,0.52627707)),aud(bri(pow(y,x),aud(y,0.8554261)),x)),max(sin(0.9449792),x)),y)),x))))),bri(bri(y,div(mul(max(add(x,tan(div(x,bri(div(0.42294335,div(bri(0.3248272,x),pow(0.7073505,y))),add(sub(pow(x,x),pow(0.14169264,0.4931891)),pow(0.6315551,aud(0.6828072,x))))))),sin(mul(x,x))),y),aud(x,y))),sub(x,0.07352328)))),bri(pow(cos(bri(add(x,sub(sub(y,sub(tan(0.27254295),pow(aud(aud(div(aud(0.70145583,cos(0.5110202)),aud(aud(y,0.36641693),bri(x,y))),add(aud(0.055077553,mul(y,0.0073604584)),bri(pow(x,x),add(y,x)))),sub(y,tan(x))),cos(y)))),add(min(bri(0.8747921,bri(x,0.27956533)),x),aud(mul(y,pow(aud(tan(aud(0.56825924,pow(y,0.14608836))),div(sub(0.43374515,min(x,x)),bri(min(x,0.27390814),0.7462468))),bri(max(y,aud(min(0.90893745,0.5301695),tan(x))),0.85812783))),bri(sub(add(x,y),div(div(sub(y,0.29068208),aud(0.71670985,min(y,x))),pow(sub(cos(x),0.73363423),y))),aud(cos(pow(max(0.5318105,min(x,y)),bri(0.30282807,add(0.34282827,x)))),aud(x,pow(aud(bri(y,x),bri(x,x)),0.86442804)))))))),div(aud(div(mul(aud(max(mul(tan(sub(max(y,0.54180956),y)),0.9020722),pow(div(bri(add(y,y),pow(x,y)),y),add(min(y,sin(y)),add(cos(y),add(0.007516384,0.50902534))))),cos(add(sin(sub(mul(x,x),tan(y))),x))),min(x,aud(sub(sub(tan(x),sin(mul(x,y))),y),cos(aud(x,y))))),div(aud(bri(y,add(div(0.19812584,pow(div(0.6232066,x),x)),bri(tan(min(y,y)),0.9355619))),y),bri(x,0.058510303))),min(bri(pow(y,aud(max(bri(tan(sub(x,y)),bri(pow(x,0.839525),cos(0.71943545))),bri(div(max(y,0.021325111),min(x,y)),add(min(0.771132,y),pow(y,y)))),0.5770025)),y),aud(bri(aud(x,aud(div(0.8857231,min(0.70264006,x)),max(pow(cos(x),mul(x,0.4746027)),mul(pow(y,x),div(x,0.078813076))))),x),aud(x,div(sin(x),max(tan(x),0.5235319)))))),0.2593689))),0.6281402),aud(div(tan(max(0.4516251,aud(y,min(aud(0.68801904,sub(pow(sub(0.7500713,min(x,max(tan(y),x))),cos(bri(sub(mul(0.521502,0.106735945),add(y,x)),pow(div(x,x),sub(0.06988287,y))))),x)),sub(y,0.20575953))))),bri(x,y)),min(0.25855398,bri(y,max(add(bri(x,0.009545088),pow(x,0.89468694)),bri(0.7647219,bri(y,div(pow(bri(cos(y),mul(max(bri(tan(y),0.0071053505),aud(y,x)),add(add(min(0.9493923,0.32693052),pow(0.53960896,y)),bri(max(x,x),max(0.45012236,y))))),sub(0.8848405,bri(aud(sub(mul(0.9815645,x),pow(x,y)),y),mul(0.08204126,max(0.70370007,x))))),sub(pow(tan(mul(mul(sub(x,0.82270455),bri(x,0.10715246)),cos(y))),x),div(mul(y,div(max(min(x,y),pow(x,x)),x)),0.9828849)))))))))));
    float b = add(bri(div(cos(max(bri(aud(bri(0.5181248,bri(y,sin(mul(x,0.54168415)))),add(0.3539586,tan(x))),x),min(mul(pow(aud(pow(x,x),tan(aud(mul(0.8287723,sin(bri(bri(y,0.36875367),y))),add(y,bri(aud(x,pow(0.96514034,x)),sin(pow(y,x))))))),add(add(cos(tan(x)),div(sin(pow(x,bri(x,div(x,x)))),mul(bri(sub(sin(y),max(x,x)),min(sub(x,x),add(y,x))),x))),mul(sin(x),0.2626052))),y),bri(x,0.6061077)))),bri(aud(x,sin(tan(tan(0.9039011)))),pow(tan(pow(x,0.45152855)),min(x,0.93309855)))),bri(div(cos(aud(min(x,sub(cos(y),sin(aud(max(add(aud(cos(pow(y,0.5854101)),sin(y)),add(max(max(y,0.2303338),aud(y,y)),mul(max(x,0.23015237),bri(x,0.16081476)))),cos(y)),x)))),x)),tan(aud(bri(aud(0.3483746,mul(aud(sin(div(0.0019347668,x)),x),0.5516496)),bri(add(x,y),max(0.9228859,pow(x,0.22043657)))),add(x,aud(pow(x,max(mul(aud(div(y,bri(y,y)),aud(bri(pow(y,y),aud(x,x)),0.13462758)),max(sin(y),x)),x)),x))))),bri(bri(x,div(mul(max(add(y,tan(div(y,bri(div(y,div(bri(y,0.23032379),pow(0.289721,0.13909078))),add(sub(pow(x,x),pow(x,0.59289074)),pow(x,aud(0.8768079,0.15438914))))))),sin(mul(y,0.10944915))),y),aud(y,x))),sub(0.550889,x)))),bri(pow(cos(bri(add(y,sub(sub(x,sub(tan(0.23869514),pow(aud(aud(div(aud(y,cos(0.101578236)),aud(aud(y,x),bri(y,0.15226889))),add(aud(0.010140896,mul(0.085466385,0.7351048)),bri(pow(0.37181377,y),add(y,x)))),sub(0.7262845,tan(x))),cos(0.05116892)))),add(min(bri(y,bri(0.34753132,x)),y),aud(mul(y,pow(aud(tan(aud(x,pow(0.009470463,0.9083476))),div(sub(0.79861856,min(y,y)),bri(min(y,0.6614344),x))),bri(max(x,aud(min(y,x),tan(x))),0.76133966))),bri(sub(add(y,0.83531284),div(div(sub(y,x),aud(0.73353934,min(0.2409141,x))),pow(sub(cos(y),x),0.31544232))),aud(cos(pow(max(x,min(x,x)),bri(x,add(x,x)))),aud(x,pow(aud(bri(0.81296587,0.67267203),bri(y,0.8755579)),x)))))))),div(aud(div(mul(aud(max(mul(tan(sub(max(x,0.6170454),x)),x),pow(div(bri(add(x,0.18090153),pow(0.8323281,y)),x),add(min(0.16733313,sin(0.46126056)),add(cos(y),add(0.74295735,0.6081791))))),cos(add(sin(sub(mul(0.98555994,0.52844167),tan(y))),0.7075529))),min(y,aud(sub(sub(tan(0.70371366),sin(mul(x,y))),0.81054807),cos(aud(x,x))))),div(aud(bri(0.637517,add(div(0.08024883,pow(div(0.06697273,x),0.0015785694)),bri(tan(min(y,y)),y))),0.63975),bri(x,x))),min(bri(pow(y,aud(max(bri(tan(sub(y,0.2849946)),bri(pow(x,0.898294),cos(y))),bri(div(max(y,0.86240077),min(0.8232589,y)),add(min(0.9698405,0.47320342),pow(y,x)))),x)),0.1365943),aud(bri(aud(y,aud(div(x,min(y,y)),max(pow(cos(y),mul(0.082102776,0.16645336)),mul(pow(x,x),div(y,x))))),0.2966349),aud(0.5682435,div(sin(0.21641302),max(tan(x),0.11397886)))))),y))),y),aud(div(tan(max(0.5296068,aud(0.3560295,min(aud(0.64607024,sub(pow(sub(0.31702566,min(x,max(tan(0.51974535),y))),cos(bri(sub(mul(y,0.69425774),add(x,0.48897028)),pow(div(0.80201626,y),sub(x,y))))),y)),sub(y,0.5108106))))),bri(0.6738794,x)),min(0.7991066,bri(x,max(add(bri(y,x),pow(y,y)),bri(0.985589,bri(x,div(pow(bri(cos(x),mul(max(bri(tan(0.16565108),y),aud(x,y)),add(add(min(0.046118736,x),pow(y,y)),bri(max(y,0.1650219),max(y,x))))),sub(0.9467683,bri(aud(sub(mul(y,y),pow(x,y)),0.4564488),mul(x,max(y,0.5454409))))),sub(pow(tan(mul(mul(sub(y,0.27754498),bri(y,0.7747407)),cos(x))),y),div(mul(0.1819458,div(max(min(y,0.00592494),pow(x,0.551162)),0.7914908)),y)))))))))));
    return vec3(r,g,b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);

    gl_FragColor = vec4(RGB.x, RGB.y, RGB.z, 1.0);
}
