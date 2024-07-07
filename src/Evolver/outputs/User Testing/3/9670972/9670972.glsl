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
    float r = min(cos(((x+(x+x))-((y+y)+(y+(0.60550976+y))))),min(bri(sin(cos(bri(tan((((y*x)/(0.64296085+0.0))/(y+0.07639074))),((x+x)-(((x-x)-(y+x))+((0.6821918-y)+(0.6560706-y))))))),(pow(((aul(((0.0-x)+(y-0.3211875)),((y*0.892703)+(y+x)))+pow((x+y),sin((y-x))))+((((x+x)+(x+0.5379029))+((x+0.6238677)+(y+x)))+(((0.88692427+y)-(y+x))+((y+y)-(0.82160443+y))))),aud(((aul((y*y),(0.83902013-x))-((0.6634603-y)+(x-0.26747808)))*(((x-0.76134914)-(x+y))+((x+0.088317275)+(x+0.6992199)))),x))*((((y+0.5705282)-x)+(((x+y)+((x+0.04452181)+(0.5736818+y)))+((0.56130946+0.10948956)+(y+(y+y)))))*((x+(y+0.094088316))*(0.5625642+((0.8228125+0.71209395)+(0.23112613+x))))))),max(cos(((0.95650166+y)+y)),var(bri(pow(pow((((0.26586628-x)+y)+((y+y)+(y-0.24767661))),(((x+y)+(x+0.79814404))+((y+y)+(0.87162244+y)))),var(var(var((x-0.7855523))))),((x+0.3542685)-((((0.71333116+x)+(0.20077515+y))+0.9359277)+(((x+y)+(y+y))+((y+y)+(y+0.54264987))))))))));
    float g = min(cos(((x+(0.08284396+y))-((y+0.392623)+(x+(0.7792348+0.24421048))))),min(bri(sin(cos(bri(tan((((0.8356111*0.24636653)/(y+y))/(y+0.58034027))),((0.30534983+y)-(((0.4940511-y)-(y+x))+((y-y)+(0.08791139-y))))))),(pow(((aul(((0.17981601-x)+(y-0.9980253)),((y*y)+(y+0.58118415)))+pow((y+y),sin((y-x))))+((((0.11863683+y)+(x+y))+((0.42215315+0.75344324)+(x+x)))+(((0.729875+y)-(y+x))+((y+y)-(y+x))))),aud(((aul((x*x),(x-y))-((x-0.56635505)+(y-y)))*(((0.28413576-x)-(y+y))+((y+y)+(0.14212471+x)))),0.84638965))*((((y+0.76661325)-0.8813451)+(((y+0.605214)+((x+y)+(y+0.20339388)))+((y+0.7341619)+(0.9683318+(0.8199672+0.18643981)))))*((x+(x+0.68835944))*(0.07088256+((0.84273416+x)+(0.37229508+y))))))),max(cos(((x+0.06281823)+x)),var(bri(pow(pow((((y-0.59715843)+y)+((y+x)+(0.9407183-x))),(((0.07686914+x)+(0.4114046+y))+((x+0.171727)+(x+y)))),var(var(var((y-x))))),((0.5796579+0.8352987)-((((x+x)+(x+0.31077164))+x)+(((0.76426166+0.34682125)+(x+y))+((y+x)+(0.5358079+y))))))))));
    float b = min(cos(((0.59671426+(x+y))-((0.49238276+x)+(x+(y+y))))),min(bri(sin(cos(bri(tan((((y*y)/(0.7022118+0.14969301))/(0.8128697+y))),((y+x)-(((0.5540378-x)-(x+x))+((0.9836517-x)+(y-y))))))),(pow(((aul(((x-x)+(0.0-0.37716883)),((0.50833046*x)+(0.84610033+y)))+pow((0.9281675+y),sin((y-0.9321681))))+((((0.46204615+x)+(y+0.18189329))+((0.9848428+y)+(0.36692625+y)))+(((y+0.69844633)-(0.27724028+x))+((0.17012778+y)-(x+x))))),aud(((aul((y*y),(y-y))-((x-y)+(x-0.44060728)))*(((0.40636584-x)-(y+y))+((0.8340558+0.21699482)+(y+0.55500984)))),x))*((((0.32177085+y)-0.74068505)+(((0.24186015+y)+((y+y)+(y+0.3966701)))+((y+0.20422035)+(x+(y+y)))))*((0.52028275+(0.69796765+x))*(x+((0.1320852+y)+(0.16442227+x))))))),max(cos(((x+x)+x)),var(bri(pow(pow((((x-x)+x)+((y+y)+(0.3533042-y))),(((y+x)+(x+x))+((x+x)+(0.9051894+0.9624131)))),var(var(var((y-x))))),((0.21201181+x)-((((0.60264874+y)+(x+y))+x)+(((x+x)+(0.96478397+y))+((y+x)+(y+0.47589344))))))))));
    return vec3(r,g,b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);

    gl_FragColor = vec4(RGB.x, RGB.y, RGB.z, 1.0);
}
