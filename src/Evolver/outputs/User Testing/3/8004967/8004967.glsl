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
    float r = max(sin(((y+0.28107673)+(((x+0.45123857)+(x+y))+((y+x)-(0.22053748+y))))),pow(aul((sin(pow(tan((((y+x)-(0.78689647+0.0))/(x+0.54435843))),((((0.7753055+x)+(0.41120225-y))-((0.5611233+0.0)+(0.9003248+0.3586229)))+(((y+0.2056232)+(x-x))+((0.5979819-y)+(0.0+0.26321507))))))/((((0.35696214+0.85446185)+(y+(y+(x+0.17101264))))+((0.25025654+y)+(x+x)))-(((y+y)+x)+(y+0.33996373)))),(pow(((aul(((0.0+x)+(y*0.10594156)),((y+x)+(x+x)))-pow((x+(x+y)),tan(sin(y))))+((((0.6001734+0.9748866)+(y+x))+((0.6714885+0.6083311)*(y+x)))+(((x-x)+(0.56691545+y))+((x+y)+(x+y))))),tan(((aud((y+0.30995724),(0.99900234*x))+((y+0.7514865)-(x-0.03914219)))-(((x+0.5383799)+(x+0.44667935))+((x+0.75004756)+(x+x))))))*(((((0.32393575+y)+((x+x)+(0.79507077+y)))-(x+y))-(((0.73584795+(x+y))+(0.20658088+y))-(((y+0.086402535)+x)+((y+y)+(x+x)))))+((0.10511398+y)+(0.3662635+(y+(y+0.031890213))))))),aul(((((((0.5366485+0.039681315)+((x+x)+x))+(((x+0.9107516)+y)+((x+0.6354688)+x)))-(((0.43399948+x)+(0.72749734+0.21071005))+((x+(0.032239974+0.0072850585))+((0.89615965+y)+(0.17378068+0.38354364)))))*(((((y+0.834484)+y)-((x+x)+(x+0.020745099)))+(x+((0.58278984+0.68302965)+(0.40723962+y))))-((((x+0.36667407)+(x+0.44122705))+(y+y))+(((0.23638415+y)+x)+((y+y)+(y+0.087249756))))))*tan((((x+(x+y))+(0.41305482+(0.4598356+0.09026438)))+((((x+y)+(y+0.82241267))+((0.5112684+x)+(0.5165693+x)))+((x+(x+x))+((0.96099293+x)+(x+0.6771886))))))),aul(min(max(min((((0.6041309-x)-(0.36695302+x))-(x*(y+0.03665947))),(((x+x)+(0.7324959+0.0))+((y+0.3210057)+(x-x)))),sin((((y+y)+(y+x))-((x-x)+(x+0.14001364))))),(((y+(x+y))+(((x+y)+(0.52070725+0.4373392))+(y+0.0621593)))+(y+x))),((x+(0.73928905+x))+(y+(x+y)))))));
    float g = max(sin(((x+0.33646113)+(((0.24466789+x)+(y+0.4831))+((x+y)-(x+y))))),pow(aul((sin(pow(tan((((0.73540497+0.3980856)-(x+x))/(0.016244173+y))),((((x+y)+(x-x))-((y+0.0)+(x+y)))+(((y+y)+(y-0.47965676))+((y-y)+(x+y))))))/((((0.6952075+0.79490626)+(y+(x+(0.63572806+x))))+((y+y)+(0.36665815+y)))-(((0.50231695+x)+x)+(0.75663364+x)))),(pow(((aul(((0.34328592+0.8367807)+(y*x)),((y+y)+(y+0.73915225)))-pow((x+(x+0.72371936)),tan(sin(x))))+((((x+0.74677944)+(y+0.047875352))+((0.2625788+0.5672585)*(x+x)))+(((y-x)+(0.07188249+y))+((0.10201717+y)+(y+x))))),tan(((aud((x+0.14636728),(x*y))+((x+x)-(y-y)))-(((0.11697985+x)+(y+y))+((x+y)+(x+x))))))*(((((y+0.7681675)+((0.31442106+y)+(x+y)))-(x+x))-(((y+(0.4833743+x))+(x+y))-(((y+x)+x)+((x+x)+(x+x)))))+((x+y)+(y+(y+(0.79186606+y))))))),aul(((((((0.5407591+x)+((0.7044373+x)+y))+(((y+x)+0.31864554)+((y+y)+0.44169116)))-(((x+y)+(0.6199204+x))+((x+(y+y))+((y+y)+(0.6043984+y)))))*(((((0.47788668+y)+x)-((x+0.23931241)+(y+0.21760243)))+(0.16665655+((x+y)+(0.2421332+0.43775833))))-((((y+x)+(0.96536225+y))+(y+0.27440053))+(((x+y)+0.53177977)+((y+x)+(x+y))))))*tan((((0.496275+(y+x))+(x+(y+x)))+((((0.2406367+x)+(x+0.30389625))+((0.7501872+x)+(x+x)))+((x+(y+0.25699925))+((y+y)+(x+x))))))),aul(min(max(min((((x-x)-(0.9051697+y))-(x*(0.9407183+y))),(((y+0.59268713)+(0.0+x))+((x+x)+(4.066229E-4-y)))),sin((((x+0.23799437)+(y+0.27461922))-((0.48338485-y)+(0.29005283+x))))),(((y+(0.9707025+y))+(((1.1175871E-4+y)+(y+x))+(x+x)))+(y+y))),((0.77640116+(x+x))+(0.11942482+(x+x)))))));
    float b = max(sin(((x+y)+(((x+y)+(0.07006717+y))+((0.79263157+y)-(y+y))))),pow(aul((sin(pow(tan((((y+y)-(0.6485594+0.0))/(x+x))),((((0.40005147+y)+(x-0.9978052))-((y+0.0)+(y+0.18011007)))+(((x+x)+(y-y))+((x-x)+(y+0.5159874))))))/((((0.18765718+x)+(x+(y+(y+0.5001751))))+((y+x)+(0.16409898+y)))-(((y+0.7702403)+y)+(0.9720626+0.5345553)))),(pow(((aul(((x+x)+(0.3745159*0.37716883)),((0.29112947+x)+(0.58543+y)))-pow((y+(0.3234542+y)),tan(sin(y))))+((((x+x)+(x+y))+((0.7685489+y)*(0.27879524+y)))+(((y-0.98032093)+(0.49541062+x))+((y+x)+(0.94497246+y))))),tan(((aud((y+0.25652128),(y*y))+((y+x)-(y-0.30970323)))-(((0.7719067+x)+(0.58866155+x))+((0.0029019713+y)+(y+x))))))*(((((y+0.3283013)+((y+x)+(0.19951165+y)))-(x+y))-(((y+(x+x))+(y+0.5991354))-(((0.8209185+0.7487535)+y)+((x+y)+(0.96570647+y)))))+((0.13558745+x)+(0.30823982+(x+(y+y))))))),aul(((((((0.54495424+x)+((x+x)+x))+(((x+y)+y)+((x+0.43858463)+x)))-(((0.4607733+x)+(0.7130588+x))+((0.4333856+(y+0.20932657))+((0.07466358+y)+(y+x)))))*(((((x+y)+x)-((y+0.27094996)+(0.2952066+x)))+(x+((x+0.3223037)+(y+y))))-((((y+0.48504996)+(0.14491153+x))+(x+0.830183))+(((y+0.022375345)+x)+((x+x)+(0.4262681+0.14971805))))))*tan((((y+(y+0.62303746))+(x+(y+0.7347073)))+((((y+y)+(0.33128643+x))+((x+y)+(x+y)))+((0.10444665+(y+0.1512276))+((x+0.42297918)+(y+0.48914516))))))),aul(min(max(min((((y-y)-(y+x))-(y*(0.5832773+y))),(((x+0.2679745)+(0.780648+x))+((0.6027483+y)+(y-y)))),sin((((y+x)+(0.7683413+0.7434305))-((0.84041476-0.18299782)+(0.9125309+x))))),(((x+(x+0.07641667))+(((y+y)+(x+0.3037026))+(0.36570096+y)))+(x+0.91229653))),((x+(0.9914346+y))+(x+(x+x)))))));
    return vec3(r,g,b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);

    gl_FragColor = vec4(RGB.x, RGB.y, RGB.z, 1.0);
}
