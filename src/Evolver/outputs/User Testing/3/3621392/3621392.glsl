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
    float r = min(sin((x+(y+y))),min(bri(((min(tan((((y+x)/(0.8243575+0.21571541))*cos((x-y)))),((x+(y+0.5540192))+(((x+x)+(x+0.0))+(x+0.36229026))))*aul(((0.25439233+(0.8205423+x))+(y+0.33469945)),((0.71921146+(0.33784997+x))+(((0.5221705+y)+x)+(y+x)))))/(x+(x+0.7384781))),(min(((aul(((0.16591269+x)+(y-0.06252761)),((y+x)-(x+x)))+pow(((y+0.24604923)+(y+x)),sin((y-x))))-(((x+0.55409557)+x)+((y+0.7969079)*(y+0.68907094)))),tan(((aud((y+y),(0.4889747+y))-((0.6634603-y)-(x+0.2802014)))-(y+(x+x)))))-x)),max((sin(((0.58793396+(x+y))+0.34875852))-cos(((x+0.7852092)+0.19545561))),var(bri(min(min((((0.79319966+x)+y)+x),(((0.4828019+0.087462544)+(y+y))+((0.17938149+x)-(y+0.2304622)))),(x/x)),x)))));
    float g = min(sin((x+(x+y))),min(bri(((min(tan((((0.62152123+0.52398044)/(x+x))*cos((x-0.8558759)))),((y+(y+0.7210579))+(((x+x)+(y+x))+(0.24359304+y))))*aul(((y+(y+x))+(0.62969685+x)),((0.72095865+(0.042212963+0.55415493))+(((0.1035372+x)+x)+(y+0.95295453)))))/(0.16519994+(x+y))),(min(((aul(((y+y)+(y-x)),((0.8041032+y)-(y+0.6095197)))+pow(((y+y)+(y+0.09535754)),sin((x-x))))-(((x+x)+x)+((x+x)*(y+x)))),tan(((aud((0.87501633+x),(y+y))-((x-0.61641455)-(y+y)))-(x+(0.19780809+0.42966664)))))-x)),max((sin(((y+(y+0.37020475))+0.854052))-cos(((0.5465412+y)+0.10550487))),var(bri(min(min((((y+0.18749106)+y)+0.70078164),(((y+x)+(y+x))+((x+0.99289745)-(0.013916016+x)))),(y/y)),0.113211036)))));
    float b = min(sin((y+(0.9879125+0.77012676))),min(bri(((min(tan((((y+y)/(0.48738956+0.3803991))*cos((x-x)))),((0.9972789+(y+0.2222541))+(((0.029958665+x)+(y+0.108507514))+(y+0.6001695))))*aul(((y+(x+y))+(y+0.98999995)),((0.17361385+(x+x))+(((0.15003258+y)+x)+(0.22592068+0.22085756)))))/(y+(y+x))),(min(((aul(((y+x)+(0.30378857-0.14839388)),((x+y)-(0.58543+y)))+pow(((x+y)+(x+x)),sin((y-x))))-(((y+0.3433131)+y)+((y+0.8866015)*(0.28565097+x)))),tan(((aud((y+x),(y+y))-((x-y)-(y+0.60151684)))-(y+(x+0.31216317)))))-y)),max((sin(((0.9938904+(y+0.59079283))+0.30487543))-cos(((y+y)+0.42476177))),var(bri(min(min((((0.6538723+y)+y)+0.5546268),(((0.52136064+y)+(y+y))+((x+x)-(x+x)))),(y/y)),x)))));
    return vec3(r,g,b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);

    gl_FragColor = vec4(RGB.x, RGB.y, RGB.z, 1.0);
}
