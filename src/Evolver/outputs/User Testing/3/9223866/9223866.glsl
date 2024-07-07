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
    float r = max(sin((x+((y+x)+(y-(y+0.720068))))),max(bri((((((x+0.008348107)+x)*(0.7220981+(x+x)))*var((((0.29015833+(x+x))+((0.5431482+0.9736689)+(0.6374241+x)))+((y+0.7552294)+(0.48422384+y)))))/((0.93234175+0.21487784)-y)),(min(((aul(((0.16591269+x)+(y-0.06252761)),((y-x)+(x-0.98838735)))-pow(((y+0.24604923)-(y+x)),sin((y-x))))+(((x+(y+x))-(x+0.0019118786))-(((x+0.7523854)+(y+y))-(y+(0.47112823+x))))),var(((aul((y+y),(0.4889747+y))-((0.6634603+y)-(x+0.2802014)))+(y+(x+(0.396573+y))))))/x)),max((cos((((y+0.22850794)+((0.5137725-(y+x))+(y+0.617501)))+(y+x)))+cos((((x+0.42069268)+(y+y))+(x+x)))),var(aul(pow(pow((((0.79319966+x)+y)+(x+(0.31189924+y))),(((0.4828019+0.087462544)+(y+y))+((0.17938149+x)-(y+0.004133217)))),(((0.9301225+x)+0.63920474)*x)),(x+(0.0986495+y)))))));
    float g = max(sin((x+((x+x)+(y-(x+0.6236762))))),max(bri((((((y+y)+0.3739645)*(x+(x+y)))*var((((0.9637522+(x+y))+((x+y)+(x+0.3555799)))+((x+x)+(0.7487147+x)))))/((y+x)-y)),(min(((aul(((y+y)+(y-x)),((0.8041032-y)+(x-0.6095197)))-pow(((y+y)-(y+0.08327329)),sin((x-x))))+(((x+(0.9502269+y))-(0.61834466+0.14163369))-(((x+y)+(y+x))-(y+(0.86977583+x))))),var(((aul((0.87501633+x),(y+y))-((x+0.61641455)-(y+y)))+(x+(0.19780809+(y+y))))))/x)),max((cos((((x+y)+((x-(x+0.14988899))+(y+x)))+(x+y)))+cos((((x+y)+(x+y))+(y+y)))),var(aul(pow(pow((((y+0.18749106)+y)+(0.29005283+(0.914708+y))),(((y+x)+(y+x))+((y+0.8520024)-(0.17040059+x)))),(((0.6352104+x)+0.3695281)*y)),(y+(y+y)))))));
    float b = max(sin((y+((x+0.16607201)+(y-(y+y))))),max(bri((((((x+0.6479593)+y)*(0.70626825+(x+x)))*var((((x+(x+0.4497916))+((x+0.85305476)+(0.968617+x)))+((x+0.114489555)+(x+0.18472749)))))/((0.7209254+y)-x)),(min(((aul(((y+x)+(0.6010813-0.30506456)),((x-y)+(0.49663478-y)))-pow(((x+y)-(x+x)),sin((y-x))))+(((y+(y+0.5005465))-(x+0.4725548))-(((x+y)+(0.64685816+0.7279975))-(0.28565097+(y+0.65630615))))),var(((aul((y+x),(y+y))-((x+y)-(y+0.5972345)))+(y+(x+(x+0.16699201))))))/y)),max((cos((((y+x)+((x-(x+0.19058096))+(y+x)))+(0.17875654+x)))+cos((((y+0.09574556)+(x+0.59017736))+(x+0.48827058)))),var(aul(pow(pow((((0.6538723+y)+y)+(x+(y+0.13027078))),(((0.24551225+y)+(y+y))+((x+x)-(x+y)))),(((0.55562496+y)+y)*y)),(0.26424444+(y+y)))))));
    return vec3(r,g,b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);

    gl_FragColor = vec4(RGB.x, RGB.y, RGB.z, 1.0);
}
