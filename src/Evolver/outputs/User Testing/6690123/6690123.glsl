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
    int varIndexFloor = int(floor(x * nVariables));
    int varIndexCeil = int(ceil(x * nVariables));

    if(varIndexFloor >= nVariables){
        varIndexFloor = nVariables - 1;
    }
    if(varIndexCeil >= nVariables){
        varIndexCeil = nVariables - 1;
    }

    float ratioValue = x - varIndexFloor;

    float valueFloor = (1 - ratioValue) * variables[varIndexFloor];
    float valueCeil = (ratioValue) * variables[varIndexCeil];
    float value = valueFloor + valueCeil;

    return value;
}

vec3 generateRGB(float x, float y){
    float r = (aul(tan(((sin(((0.672494+0.24053586)+(((y+y)+(0.65503746+x))-x)))-((((y+(0.34465975+(0.21906674+y)))+((((y+y)+x)+(0.44224012+0.98043877))+(x+y)))+y)+(((x+x)+(0.465855+((y+y)+0.6615944)))+(((x+(x+y))+(x+x))+((0.9983427+((y+y)-x))-(((y+0.13571566)+(x+y))+(x+(x+0.8920153))))))))+(((((0.8662757+0.39587188)+((x+y)+(0.90365016+0.37735552)))+((((x+(0.7963609+x))+x)+(y+x))-(((y+(0.36545455+y))+y)-(x+(x-y)))))+aul(cos((sin(pow((0.0*0.07894604),cos(0.0)))*((0.29873818+(x+x))+((0.85021216+0.47417307)+(0.25825223-y))))),sin(pow((((x+x)+(x+y))+((y+x)-sin(0.18894434))),(((x+0.7032108)+(y+y))*(y+(x+x)))))))*((((x+x)+0.64137626)+y)-(0.96305984+0.30617952))))),cos((((0.63431346+y)+((0.64789563+(x+0.066412926))+y))/((((0.46261436+x)+0.8659823)-y)+((((((0.961629+y)-(0.50668484+x))+(x+(y+0.65637034)))+((x+x)+(y+(x+x))))+((x+x)+((0.15365732+0.82535934)+(x+y))))+(x+((x+0.7868085)+y)))))))+(((((((x+(0.41390973+x))+((0.31139034+x)+(x+(0.74547493+x))))*((((0.0077944994+0.08524275)+y)+((y+x)+(y+0.47346085)))*((((y+x)+0.05535364)+y)+(0.8244567+(0.40248495+0.3764609)))))-((0.8355864+0.656893)+(((y+x)+y)+(x+0.4962927))))*(((y+y)+((((x+y)+((x+0.7905094)+((x+0.8974927)+y)))+x)-((y+x)+(y+0.9314348))))-((((((x+(y+0.968214))+(x+0.6815032))-((y+x)+(x+y)))+(((0.1855334+y)+0.46315402)+((x+y)+(0.16754365+(x+0.36500555)))))+(((0.83462334+x)-(0.17182982+y))-((y+0.42221546)+(x+y))))+((x+x)+x))))-(((((y+y)+(0.2690962+(0.18611509+0.4081319)))+((((x+y)+y)+(y+y))+(y+(x+0.013246894))))+((((((y+0.96831036)+0.40765804)+(x+(y+x)))+(0.8261213+(x+x)))-0.17658305)-((((y+x)+(0.66218984+0.4209264))-(y+(y+y)))+(((x+y)+x)+y))))+(((0.5053809+((((x+x)+(0.33783728+0.7757934))+(y+(x+x)))-(y+((0.18554896+x)+0.7666211))))-(((0.46745932+0.7951584)+(y+0.22114563))+(x+0.91607165)))+(((x+x)+(y+0.59229773))+((((0.39107198+y)+y)+0.13133276)+((y+0.590297)-(y+0.21128118)))))))/0.47520536));
    float g = (aul(tan(((sin(((y+x)+(((0.56086546+x)+(x+0.24550563))-0.0513407)))-((((y+(x+(0.003868997+0.72861135)))+((((x+y)+y)+(x+x))+(y+y)))+x)+(((y+x)+(x+((0.042966485+y)+0.9392116)))+(((x+(y+0.043127418))+(0.5561789+y))+((x+((x+0.5743559)-x))-(((x+y)+(0.7295564+y))+(0.518898+(y+y))))))))+(((((y+0.4839735)+((0.01803124+x)+(y+0.7195782)))+((((0.57612777+(0.67213726+x))+x)+(y+0.20673144))-(((x+(0.8283155+0.2890193))+x)-(x+(y-0.510971)))))+aul(cos((sin(pow((0.0*0.18659839),cos(0.0)))*((y+(0.28094494+y))+((y+y)+(x-0.759801))))),sin(pow((((x+0.72701615)+(x+0.776023))+((x+x)-sin(0.17890769))),(((x+0.30575913)+(y+0.7252449))*(x+(y+x)))))))*((((y+y)+0.94314426)+0.6368485)-(y+y))))),cos((((x+0.0025801063)+((x+(x+y))+x))/((((y+0.1901654)+y)-x)+((((((x+y)-(x+y))+(y+(x+y)))+((y+y)+(y+(y+0.9544274))))+((x+x)+((y+x)+(y+x))))+(y+((x+y)+y)))))))+(((((((y+(0.10042906+x))+((0.4167012+x)+(x+(y+0.21228719))))*((((y+y)+0.8054761)+((y+0.53876495)+(x+0.16332096)))*((((x+0.4289378)+x)+y)+(y+(x+x)))))-((y+x)+(((y+x)+0.6228381)+(0.5839956+x))))*(((0.70261323+y)+((((0.68138874+x)+((0.44432044+0.26925462)+((x+x)+x)))+x)-((y+0.10707843)+(0.3365296+y))))-((((((y+(x+0.20452541))+(x+x))-((0.15164548+x)+(y+0.5563744)))+(((0.12979656+0.03139347)+y)+((x+0.40425003)+(x+(y+0.3374074)))))+(((y+y)-(x+0.36822706))-((x+y)+(0.8966063+y))))+((x+x)+0.27256125))))-(((((y+0.7090831)+(x+(0.71340233+x)))+((((0.58569735+y)+0.06190145)+(0.03611183+0.95035243))+(0.17396647+(y+y))))+((((((y+x)+y)+(x+(0.9740383+y)))+(0.22403955+(x+y)))-x)-((((0.9440625+y)+(y+y))-(0.6226564+(0.69693553+x)))+(((y+y)+0.8068369)+y))))+(((0.35649866+((((x+y)+(0.8222662+0.9455711))+(x+(x+0.32461452)))-(0.7716921+((x+0.40415132)+x))))-(((0.76976967+x)+(y+0.7470766))+(x+y)))+(((0.6311016+0.03355497)+(x+y))+((((x+0.54281205)+y)+0.93890065)+((x+y)-(y+y)))))))/0.138785));
    float b = (aul(tan(((sin(((y+y)+(((x+x)+(x+x))-x)))-((((x+(y+(y+y)))+((((x+y)+0.9990347)+(y+x))+(0.8550791+0.28922546)))+x)+(((x+y)+(y+((x+x)+y)))+(((y+(x+0.74649274))+(y+y))+((0.4002775+((0.13774002+y)-0.6227165))-(((y+y)+(y+y))+(y+(x+0.3687247))))))))+(((((x+x)+((0.34191352+0.24464428)+(0.74383825+0.8666003)))+((((x+(y+x))+x)+(x+y))-(((0.60768396+(y+y))+y)-(y+(0.8740502-y)))))+aul(cos((sin(pow((0.09340867*0.0),cos(0.0)))*((x+(x+y))+((0.1920687+0.04641652)+(0.12398643-0.7326624))))),sin(pow((((y+x)+(x+y))+((y+x)-sin(0.0))),(((0.14437866+0.7616644)+(x+x))*(x+(y+x)))))))*((((0.94901544+y)+y)+x)-(0.58904564+x))))),cos((((x+y)+((x+(0.33153212+0.5847793))+y))/((((y+0.39656943)+x)-0.42901397)+((((((y+x)-(x+0.38192832))+(y+(0.02494973+x)))+((x+x)+(0.6954841+(0.9951092+x))))+((0.60762745+y)+((x+y)+(y+x))))+(y+((x+0.8631406)+y)))))))+(((((((y+(0.2698635+y))+((0.55057955+0.8511388)+(x+(0.1255526+x))))*((((y+x)+x)+((y+x)+(y+y)))*((((x+y)+x)+0.5892779)+(0.036383092+(y+0.65092117)))))-((y+0.91986805)+(((y+0.85969055)+x)+(y+y))))*(((0.36887795+y)+((((0.6519681+x)+((x+x)+((0.68842095+0.28721917)+x)))+y)-((x+x)+(x+y))))-((((((x+(x+y))+(x+0.90049))-((0.64173675+y)+(0.17777056+y)))+(((y+y)+0.54623616)+((y+x)+(y+(0.5301427+0.7632356)))))+(((y+x)-(y+0.11065149))-((y+x)+(x+0.8430281))))+((y+0.68923473)+0.88000774))))-(((((0.64351845+0.9264291)+(y+(y+x)))+((((y+y)+0.66764474)+(x+0.15036374))+(0.5832383+(y+x))))+((((((x+x)+y)+(0.27637196+(y+x)))+(x+(0.3699578+x)))-y)-((((x+x)+(y+0.17599761))-(0.9221075+(x+y)))+(((y+y)+0.99833214)+0.11100197))))+(((y+((((x+y)+(x+0.14155465))+(x+(0.7880822+0.5824501)))-(y+((x+0.077970564)+0.6025112))))-(((0.5829+0.6505664)+(0.90725094+y))+(x+x)))+(((x+x)+(0.60863256+y))+((((y+x)+y)+x)+((x+x)-(y+y)))))))/x));
    return vec3(r,g,b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);

    gl_FragColor = vec4(RGB.x, RGB.y, RGB.z, 1.0);
}
