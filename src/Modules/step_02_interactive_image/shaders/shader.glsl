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
    float r = bri(sub(sub(x,aud(max(x,min(add(aud(0.9768419,sub(0.3075261,pow(bri(max(div(x,0.10222292),0.94653654),add(div(add(y,y),bri(y,y)),mul(y,x))),sub(add(pow(aud(0.6689472,x),bri(y,0.93269944)),y),mul(bri(y,min(0.887624,0.4745555)),aud(aud(x,0.62919617),aud(y,0.677114))))))),0.10970092),bri(pow(x,max(bri(y,sin(sub(max(sin(0.38996315),x),y))),sub(cos(x),x))),cos(x)))),tan(bri(y,div(0.78227496,aud(div(min(mul(tan(bri(add(x,x),mul(x,x))),aud(pow(tan(x),x),min(y,x))),add(max(pow(x,y),0.921124),x)),0.34050035),cos(min(0.74756,tan(x))))))))),x),tan(y));
    float g = bri(sub(sub(0.20739532,aud(max(0.33987236,min(add(aud(y,sub(0.50172424,pow(bri(max(div(0.70812225,y),0.37425303),add(div(add(y,0.06305885),bri(y,0.36314416)),mul(x,0.4617591))),sub(add(pow(aud(y,x),bri(y,x)),0.013477325),mul(bri(0.47503448,min(0.7788482,x)),aud(aud(x,x),aud(y,x))))))),0.32300472),bri(pow(0.5283973,max(bri(y,sin(sub(max(sin(0.15553236),y),y))),sub(cos(x),x))),cos(0.50465727)))),tan(bri(y,div(y,aud(div(min(mul(tan(bri(add(x,x),mul(x,0.9861231))),aud(pow(tan(0.23406696),0.12269521),min(0.17251039,x))),add(max(pow(y,0.5064111),0.8125887),0.61641216)),y),cos(min(x,tan(0.7974663))))))))),0.23041129),tan(x));
    float b = bri(sub(sub(x,aud(max(0.3542056,min(add(aud(y,sub(x,pow(bri(max(div(y,y),y),add(div(add(x,0.7795067),bri(x,0.11651993)),mul(y,y))),sub(add(pow(aud(0.8657167,y),bri(y,y)),y),mul(bri(0.24765015,min(y,x)),aud(aud(y,0.5949652),aud(y,0.47748947))))))),y),bri(pow(x,max(bri(y,sin(sub(max(sin(x),y),0.4904356))),sub(cos(x),0.6221378))),cos(0.038129807)))),tan(bri(x,div(0.9545708,aud(div(min(mul(tan(bri(add(x,x),mul(y,0.5758202))),aud(pow(tan(x),x),min(x,0.07007265))),add(max(pow(x,x),x),y)),y),cos(min(0.8614459,tan(x))))))))),x),tan(0.3876071));
    return vec3(r,g,b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);

    gl_FragColor = vec4(RGB.x, RGB.y, RGB.z, 1.0);
}
