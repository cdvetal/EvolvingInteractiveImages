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
    float r = (((((((x+0.24810773)*(y+y))-((x+x)+(((0.8186213+(0.8335751+y))+((0.7338581+x)+(x+0.3221315)))+((y+(0.3097238+y))+(0.28879702+(y+0.70119846))))))+((x+((((x+x)+y)+0.1696415)+(0.26380706+x)))*(x+0.34883595)))-(((((((x+y)+(y+y))+(0.49466622+y))+((x+y)+(0.35224128+(y+0.97840244))))+0.9944696)+(((((y+x)+x)+(x+x))+(((0.58173984+y)+(x+y))+(0.91663885+x)))-(((x+0.29690033)+(x+y))+(x+(x-(0.9522443+x))))))*(var(sin((((((0.1879785+y)+(y+0.29933363))-((y+x)-x))+(((x-x)+(x+x))+((x+0.62813294)+(y*x))))+((((x+y)+(y+y))+(0.68209094+(x+0.32488078)))+0.73307705))))+((((0.34217548+0.061154008)+((x+x)+x))+(((y+x)+(y+x))+(y+y)))+(((0.33713275-((y+(y+y))+((x+0.93193334)+x)))-(0.7359284-(((x+x)+(x+y))+((x+0.60556555)+0.9087038))))-((0.7146342+x)-((y+(y+(y+x)))+((y+(x+0.32466102))+(x-(y+y))))))))))+((((0.99813634+(x+(y+y)))-(((x+y)+(y+x))+(((0.5319881+0.095500946)+y)+(y+x))))-tan((min((((((x+y)-(0.8901452-y))-((0.63413036+y)-(y+x)))+(((y+y)*(x*x))+((0.62062573+0.380327)+(y-y))))*((((y+y)+(0.49711043+y))-((0.9281067+x)+(y+y)))+(((0.7645365+x)+(y+0.20849687))+(y+x)))),bri((cos(bri((0.14175633*x),y))-pow(((x+y)+0.41357106),pow((y+y),bri(0.0,0.0)))),min((((0.19068629+x)+(0.71681803-0.2235809))*((0.13660192-0.0)/bri(0.29836816,y))),((tan(0.33404526)-0.6654389)*tan((0.09889948+y))))))+((((((x+0.51067436)+(x+y))+(x+0.8392151))+(((x+0.36237502)+(0.59423286+y))+((x+y)+(y+0.8775528))))-((((y+y)+y)+((0.439049+y)+(0.33780867+0.60701376)))+(((0.5665494+0.048214674)+(x+y))+((0.18652797+x)+(x+y)))))+(((((0.42304945+x)+0.20504987)+(0.45468092+(y+x)))+((y+(x+x))-((0.20127904+0.7665712)+(y+0.4445579))))+((((x+0.13791776)-y)-((y+y)*(x+0.1574133)))-(((x-9.0222806E-5)+(y-0.6804378))*((y+y)+(y+x)))))))))+((((y+((((0.71522784+y)+(x+0.24289423))+(0.79815817+(0.36593556+y)))+(0.238038+(y+y))))+((((x+0.3961106)+x)+(x+x))+x))+(((((0.17688113+x)-y)+(y+(y+x)))+(y+x))-((y+y)+((x+0.75446355)+y))))-(((x+(x+0.91047585))+(((y+y)+(y+x))+((0.7962849+0.20875454)+(0.8995941+y))))-((x-((x+(0.4044358+x))+((x+(y+x))+((0.6394431+0.5068184)+(x+x)))))-(y+0.05710119))))))/((0.024790227+y)+(x+(x+y))));
    float g = (((((((y+y)*(x+y))-((x+x)+(((x+(y+y))+((0.93337154+x)+(0.4254924+0.4793238)))+((y+(x+0.97228414))+(y+(y+x))))))+((0.45208973+((((x+x)+0.22932029)+x)+(0.49563664+x)))*(0.70909864+x)))-(((((((x+x)+(y+0.557399))+(x+0.7144793))+((y+0.80555123)+(0.3992055+(0.6862809+0.5540571))))+x)+(((((0.8439717+x)+y)+(x+0.5526994))+(((y+0.43262154)+(x+x))+(x+0.05358392)))-(((y+y)+(x+y))+(y+(x-(y+0.75714576))))))*(var(sin((((((x+y)+(0.7563189+0.99377954))-((x+0.10073161)-x))+(((x-x)+(0.62199354+x))+((0.037652135+x)+(0.4610163*x))))+((((y+y)+(0.12768316+x))+(0.7705461+(y+y)))+y))))+((((y+0.6946013)+((y+y)+y))+(((0.16712075+x)+(x+y))+(x+y)))+(((y-((0.018252432+(x+y))+((0.1485613+x)+y)))-(x-(((y+0.3180145)+(0.7500889+0.83369297))+((x+x)+y))))-((x+0.5870735)-((y+(y+(x+x)))+((x+(0.42814028+x))+(y-(0.62850577+x))))))))))+((((x+(x+(x+y)))-(((x+x)+(0.215415+x))+(((x+0.27301723)+y)+(x+0.16171378))))-tan((min((((((x+0.7894977)-(0.11751786-y))-((x+x)-(0.7057014+0.82073075)))+(((0.9817418+x)*(y*x))+((0.61949044+0.34183306)+(y-0.15076011))))*((((0.25997645+x)+(0.777471+0.7863105))-((0.03040123+x)+(0.87655985+0.18408787)))+(((y+0.66390824)+(x+y))+(0.79798186+x)))),bri((cos(bri((0.0*y),x))-pow(((0.14859653+0.60133606)+y),pow((x+0.8451934),bri(0.026922986,0.0)))),min((((y+y)+(0.6848983-y))*((0.0-0.09318604)/bri(0.04281694,y))),((tan(0.0)-y)*tan((y+x))))))+((((((x+x)+(0.30729818+x))+(x+0.030745983))+(((y+y)+(y+x))+((0.8222471+y)+(y+x))))-((((y+x)+y)+((x+y)+(0.3326295+0.632449)))+(((x+x)+(y+y))+((0.24803066+x)+(0.50396633+0.92259854)))))+(((((0.05390972+0.41012174)+x)+(0.15029633+(y+x)))+((x+(y+y))-((y+0.99583876)+(y+x))))+((((x+0.805089)-y)-((0.26186138+x)*(y+x)))-(((x-0.7969249)+(x-y))*((x+y)+(0.894866+0.24018359)))))))))+((((x+((((x+y)+(x+0.1231429))+(y+(0.89518976+0.22619373)))+(y+(x+0.019554019))))+((((y+0.14279956)+x)+(x+x))+0.69447434))+(((((x+y)-y)+(0.18703794+(x+x)))+(x+y))-((x+x)+((0.8404886+x)+0.9304667))))-(((x+(y+0.59207994))+(((0.64515084+x)+(y+x))+((y+0.8968588)+(y+x))))-((0.95361185-((x+(0.70027435+y))+((0.338081+(x+0.91587406))+((x+x)+(x+x)))))-(x+0.85505337))))))/((y+x)+(0.46230912+(y+y))));
    float b = (((((((0.126356+0.9755929)*(x+0.15524894))-((x+y)+(((0.8206195+(x+y))+((0.4468106+y)+(0.08475673+0.6225804)))+((0.92994636+(0.95383054+0.9577929))+(y+(y+x))))))+((y+((((x+y)+x)+x)+(0.92204136+0.7252257)))*(x+x)))-(((((((y+y)+(y+y))+(0.4862185+y))+((x+0.9947684)+(0.7346054+(0.338584+x))))+x)+(((((x+x)+x)+(x+y))+(((0.92972964+0.19250357)+(x+0.7320762))+(0.8983188+x)))-(((y+y)+(x+y))+(y+(y-(0.114660144+x))))))*(var(sin((((((x+y)+(y+y))-((x+0.7136305)-x))+(((x-x)+(y+x))+((0.41376257+y)+(y*y))))+((((y+y)+(x+y))+(x+(x+x)))+x))))+((((0.11035627+y)+((y+y)+y))+(((0.38704705+x)+(x+y))+(0.5514609+0.3672409)))+(((x-((x+(x+x))+((x+0.5598648)+x)))-(y-(((0.21417886+x)+(x+0.08520931))+((0.35704637+x)+0.37356395))))-((y+x)-((y+(0.9487676+(x+x)))+((0.31040794+(y+y))+(y-(y+x))))))))))+((((0.6666042+(0.654692+(0.6582579+y)))-(((y+x)+(0.7335468+x))+(((y+0.5312519)+y)+(x+0.07697368))))-tan((min((((((y+0.9356813)-(0.0-y))-((y+x)-(x+0.6252041)))+(((0.12881899+x)*(y*x))+((0.6438049+x)+(y-y))))*((((y+y)+(x+0.6781313))-((0.100623965+0.44602275)+(x+x)))+(((x+x)+(0.55413043+y))+(x+0.7449079)))),bri((cos(bri((0.16542038*y),0.22181565))-pow(((x+x)+0.15000468),pow((y+0.24667633),bri(0.071741536,0.08050304)))),min((((x+x)+(0.07543963-x))*((0.0-0.0)/bri(0.0,x))),((tan(0.25082162)-0.9446531)*tan((y+0.41177642))))))+((((((y+0.020268738)+(x+0.29298985))+(y+y))+(((x+x)+(x+x))+((y+x)+(y+x))))-((((0.0+y)+0.2925743)+((x+y)+(x+0.38674092)))+(((y+0.8857096)+(y+y))+((y+x)+(y+y)))))+(((((x+x)+y)+(0.070372224+(y+y)))+((x+(0.88773537+y))-((x+y)+(0.9016165+x))))+((((0.18426293+0.1638844)-y)-((0.46068656+y)*(0.39089736+y)))-(((x-x)+(y-y))*((x+y)+(x+0.15186474)))))))))+((((y+((((x+x)+(x+y))+(0.41784257+(0.4053769+y)))+(x+(x+0.350456))))+((((y+y)+y)+(y+x))+0.8027374))+(((((x+y)-x)+(0.41460997+(y+x)))+(y+y))-((y+y)+((y+y)+0.62213516))))-(((0.56293166+(y+x))+(((x+x)+(x+x))+((x+y)+(0.83899+y))))-((y-((y+(0.6707972+x))+((0.75723606+(x+y))+((x+0.8212175)+(y+0.38613313)))))-(0.31212294+x))))))/((0.7398491+y)+(y+(x+0.777397))));
    return vec3(r,g,b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);

    gl_FragColor = vec4(RGB.x, RGB.y, RGB.z, 1.0);
}
