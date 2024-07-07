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
    float r = bri(sin(((y+y)+(((x+x)+x)+((y+y)+(0.44061863+x))))),pow(bri(((min(tan((((y*x)/(0.8312153*0.104918964))-sin((x+y)))),((((x+y)+(x+y))-((y+x)+0.5540192))+(((x+x)-(x-0.0))*(x+(x+x)))))-aul(((((y+0.11866218)+(0.7134154+y))+((0.5431482+x)+(0.6374241+x)))+(y-(y+y))),(((x+(0.9581049+0.09184724))+(0.33784997+(x+x)))+(((0.27012455+y)+(x+y))-((x+0.90813106)+(0.60619265+x))))))/(x-(x+((y+x)+y)))),(min(((aud(((0.26908013+x)*(y-0.06252761)),((y-x)-(x+0.98838735)))+pow(((y+0.24604923)+(y+x)),cos((y+x))))+((((x+y)+(y+x))+((y+0.75833774)+0.0019118786))-(((x+0.7523854)+(y+y))-((y+y)+(x+0.83856833))))),tan(((aud((0.0+y),(0.4889747-y))*((0.9144636*y)+(x+0.2802014)))-(y+(x+(0.396573+y))))))-(y+y))),max((cos(((((0.69152033+0.9244584)-x)+(((y+x)+(x+x))+y))+(((0.55358076+x)-(x+y))+x)))-(((((0.4441781+(x+x))+0.42069268)+(0.33333045+y))+((x+x)+y))/x)),tan(max(max(min((((0.79319966+x)+(x+x))+((0.34505153+0.03229755)+0.14001364)),(((0.2896384+0.087462544)+(y+y))+((0.17938149+x)-(y+0.004133217)))),((x+((x+0.66770625)+(y+y)))/((x+y)+y))),((x+x)+(y+(y+x))))))));
    float g = bri(sin(((x+y)+(((0.6531726+y)+x)+((y+0.5777809)+(y+y))))),pow(bri(((min(tan((((0.56021476*0.52398044)/(x*y))-sin((x+0.7045423)))),((((y+x)+(0.7411031+x))-((0.93654424+x)+0.7210579))+(((x+x)-(y-x))*(0.24359304+(0.5948534+0.825786)))))-aul(((((0.6293884+0.8392317)+(x+x))+((x+y)+(x+0.3555799)))+(0.62969685-(x+x))),(((0.92834455+(0.44618887+y))+(0.042212963+(0.41620022+y)))+(((0.22277817+x)+(y+x))-((x+0.2459904)+(0.68763256+y))))))/(0.16519994-(x+((x+0.935449)+x)))),(min(((aud(((y+y)*(y-x)),((0.8041032-y)-(x+0.6095197)))+pow(((y+y)+(y+0.09535754)),cos((x+x))))+((((0.34880805+x)+(0.7236154+y))+((y+0.7426715)+0.14163369))-(((x+y)+(0.78948426+x))-((x+x)+(0.56735784+x))))),tan(((aud((0.0+x),(y-y))*((x*0.61641455)+(y+y)))-(x+(0.19780809+(y+y))))))-(y+y))),max((cos(((((y+y)-y)+(((0.059889615+x)+(x+y))+0.37020475))+(((0.6050697+y)-(x+y))+y)))-(((((0.51474005+(x+y))+y)+(y+y))+((y+x)+y))/x)),tan(max(max(min((((y+0.18749106)+(y+0.97944564))+((y+y)+x)),(((y+x)+(y+x))+((y+0.99289745)-(0.17040059+x)))),((x+((0.64570177+y)+(x+0.029467463)))/((0.977567+0.19487482)+x))),((x+y)+(y+(0.9482619+0.3135445))))))));
    float b = bri(sin(((y+x)+(((y+0.12806922)+0.16607201)+((0.23811722+y)+(x+0.28089935))))),pow(bri(((min(tan((((y*y)/(0.74590826*0.44918767))-sin((x+x)))),((((y+x)+(0.44645387+0.82583714))-((x+y)+0.2222541))+(((0.029958665+x)-(y-0.108507514))*(y+(y+0.23022974)))))-aul(((((y+x)+(x+0.9421091))+((x+0.85305476)+(0.968617+x)))+(y-(x+y))),(((y+(x+y))+(x+(y+x)))+(((0.15003258+y)+(x+x))-((0.8320114+x)+(y+y))))))/(y-(y+((0.61104655+0.9890222)+x)))),(min(((aud(((y+x)*(0.30378857-0.14839388)),((x-y)-(0.49663478+y)))+pow(((x+y)+(x+x)),cos((y+x))))+((((x+0.57022476)+(y+0.5005465))+((0.44216734+y)+0.4725548))-(((x+y)+(x+y))-((x+y)+(y+y))))),tan(((aud((0.0+x),(y-y))*((x*y)+(y+0.60151684)))-(y+(x+(x+0.16699201))))))-(y+y))),max((cos(((((0.23487014+y)-y)+(((0.8786368+x)+(x+x))+0.59079283))+(((0.9272121+y)-(x+y))+x)))-(((((x+(x+0.18543524))+0.09574556)+(x+y))+((x+y)+y))/0.81295735)),tan(max(max(min((((0.6538723+y)+(0.9990458+0.22757739))+((0.3010978+0.40930456)+x)),(((0.52136064+y)+(y+y))+((x+x)-(x+y)))),((x+((0.20884466+x)+(x+y)))/((x+y)+x))),((x+y)+(y+(x+0.71845686))))))));
    return vec3(r,g,b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);

    gl_FragColor = vec4(RGB.x, RGB.y, RGB.z, 1.0);
}
