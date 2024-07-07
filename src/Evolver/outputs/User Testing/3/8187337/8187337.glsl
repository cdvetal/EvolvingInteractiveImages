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
    float r = min(sin((x+0.44826204)),min(bri(((min(cos(sin(((y*x)*(0.64296085+0.0)))),(((0.14256477+0.3602296)-((y+x)+(0.11494017+0.7067712)))+(((x+0.9748167)+(y+x))+((0.79447013+y)+(0.25100023+y)))))*aul(((0.25439233-(y+y))+x),(((y+x)+(y+x))+((y+x)+((y+0.44492573)+(0.7919973+y))))))/0.49937582),(pow(((aul(((0.014716566+x)+(y+0.06252761)),((y+0.892703)+(x+x)))+pow((0.43842244+x),((y+x)/(0.51549315+0.4201398))))+((0.2157569+((0.9128927-0.6238677)+(y+x)))+(0.22417313+(x+0.78371537)))),tan(((aul((y+y),(0.83902013+x))-((0.6634603+y)-(x-0.03914219)))*((x+0.44600898)+(y+x)))))-((0.19466525+x)+x))),bri(cos(y),var(bri(pow(min((0.33349764+((y+y)+(y+0.24767661))),(((x+y)+0.11922866)+(0.41271454+(0.87162244+y)))),cos(((x+y)+(0.8417219+(y+y))))),(x+y))))));
    float g = min(sin((x+y)),min(bri(((min(cos(sin(((0.58397156*0.3739645)*(x+x)))),(((0.41563904+x)-((x+0.45710385)+(y+0.22024745)))+(((0.4940511+y)+(y+x))+((y+y)+(0.4299397+y)))))*aul(((y-(0.8009754+y))+y),(((0.30180466+0.62316155)+(0.07726568+0.82790995))+((y+0.4508357)+((x+0.19744527)+(x+x))))))/0.21720529),(pow(((aul(((0.34328592+0.80364937)+(y+x)),((y+y)+(y+0.73915225)))+pow((0.52704567+y),((x+x)/(y+x))))+((y+((0.2625788-0.75344324)+(x+x)))+(x+(x+x)))),tan(((aul((x+x),(x+y))-((x+0.56635505)-(y-y)))*((x+y)+(y+y)))))-((0.6091987+y)+0.6858287))),bri(cos(0.45760256),var(bri(pow(min((x+((y+x)+(0.9407183+x))),(((0.088020444+y)+x)+(y+(x+y)))),cos(((x+x)+(0.6159666+(y+0.721847))))),(0.5755645+0.91636276))))));
    float b = min(sin((x+x)),min(bri(((min(cos(sin(((y*y)*(0.70626825+0.14969301)))),(((x+0.3953213)-((0.77235174+x)+(0.26103115+y)))+(((0.5540378+x)+(x+x))+((x+x)+(y+y)))))*aul(((y-(y+x))+y),(((x+x)+(0.40303302+0.29143023))+((y+x)+((0.7763057+0.26801187)+(y+x))))))/0.1884656),(pow(((aul(((x+x)+(0.3745159+0.37716883)),((0.29112947+x)+(0.72340876+y)))+pow((0.89192784+x),((y+x)/(0.5094039+x))))+((y+((0.9848428-y)+(0.27879524+y)))+(0.027064383+(y+x)))),tan(((aul((y+x),(y+y))-((x+y)-(y-0.60151684)))*((y+x)+(0.54561836+x)))))-((0.25865114+y)+y))),bri(cos(0.89970124),var(bri(pow(min((x+((y+x)+(0.3533042+y))),(((y+y)+0.39371145)+(x+(0.9051894+x)))),cos(((y+y)+(0.4138071+(0.25758165+y))))),(x+0.9543725))))));
    return vec3(r,g,b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);

    gl_FragColor = vec4(RGB.x, RGB.y, RGB.z, 1.0);
}
