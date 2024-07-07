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
    float r = min(tan((y+y)),min(bri(((min(tan(sin(((y-x)*(0.64296085-0.0)))),(((0.14256477+(y+0.6777127))+(0.015886009-0.11639106))+(((y+x)+y)+((0.79447013+y)+x))))*aul((((y+x)-(0.64347893+y))+x),(((y+x)+(y-x))+((y+x)+((y+0.44492573)+y)))))-(0.9381298+x)),(pow(((aud(((0.014716566+x)+(y*0.11162176)),((y+0.892703)+(x+x)))+min(x,sin((y+x))))+((0.2157569+((0.9128927+0.9057474)+(y-x)))+((0.6050502+0.46763724)+(x+(y+0.1354326))))),tan(((aud((y+y),(0.8403234*x))-((0.6634603+y)+(x+0.03914219)))*(x+(y-(0.9917797+y))))))-((0.19466525+(x+y))+x))),bri(((((x+y)+((y+0.30927837)+(x+(y+x))))/((((x+y)+(x+0.7605103))+(x+(x+y)))*(0.28224957+0.8624078)))-tan((y+0.21398556))),aud(bri(min(pow((0.33349764+((0.48644274+0.730012)+(y+0.24767661))),((x+0.11922866)+((y+x)+x))),tan(((y+0.025561988)+((y+x)+x)))),x),0.16877729))));
    float g = min(tan((y+0.5848814)),min(bri(((min(tan(sin(((0.75714844-0.3739645)*(x-x)))),(((0.41563904+(0.64231306+x))+(y-y))+(((y+x)+x)+((y+y)+x))))*aul((((0.8962083+y)-(y+0.19353712))+y),(((0.30180466+0.62316155)+(0.07726568-0.82790995))+((y+0.4508357)+((x+0.19744527)+0.71805024)))))-(0.13334316+0.76905584)),(pow(((aud(((0.5400063+0.80364937)+(y*x)),((y+y)+(y+0.73915225)))+min(y,sin((x+x))))+((y+((0.46349037+0.75344324)+(x-x)))+((0.5367624+y)+(x+(x+y))))),tan(((aud((x+x),(x*y))-((x+0.23247443)+(y+y)))*(0.7801271+(y-(y+0.95884))))))-((0.6091987+(y+y))+0.6858287))),bri(((((0.7732308+x)+((x+y)+(y+(y+x))))/((((x+y)+(0.6407377+y))+(0.16665655+(y+y)))*(0.5275145+y)))-tan((y+x))),aud(bri(min(pow((x+((y+y)+(0.9407183+x))),((y+x)+((x+x)+x))),tan(((x+y)+((x+0.64511454)+y)))),0.113211036),y))));
    float b = min(tan((y+0.5782744)),min(bri(((min(tan(sin(((y-y)*(0.70626825-0.21636786)))),(((x+(0.39951736+0.6758498))+(x-0.6960161))+(((x+0.2956506)+x)+((x+x)+0.963207))))*aul((((x+y)-(x+x))+y),(((x+x)+(0.40303302-0.29143023))+((y+x)+((0.7763057+0.5593212)+x)))))-(x+y)),(pow(((aud(((x+x)+(0.3745159*0.5593398)),((0.29112947+x)+(0.58543+y)))+min(x,sin((y+x))))+((y+((0.9398794+y)+(0.27879524-y)))+((x+y)+(y+(y+0.8434993))))),tan(((aud((y+x),(y*y))-((x+y)+(y+0.75985265)))*(y+(0.54561836-(x+0.39562976))))))-((0.25865114+(0.80006737+x))+y))),bri(((((y+y)+((x+y)+(x+(y+y))))/((((x+y)+(y+y))+(x+(0.4535678+0.10662693)))*(x+y)))-tan((0.78715986+0.26273257))),aud(bri(min(pow((x+((x+x)+(0.5832773+y))),((0.043753088+0.39371145)+((x+x)+x))),tan(((y+y)+((y+y)+y)))),x),0.62205684))));
    return vec3(r,g,b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);

    gl_FragColor = vec4(RGB.x, RGB.y, RGB.z, 1.0);
}
