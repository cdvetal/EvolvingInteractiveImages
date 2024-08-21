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
    float r = tan(pow(min(pow(add(pow(0.43620753,0.26802635),0.93255186),div(cos(0.010953426),max(sub(add(pow(cos(y),0.52419996),add(x,min(y,y))),add(min(pow(min(y,sin(add(add(y,0.5464945),tan(y)))),bri(tan(tan(aud(x,y))),0.41379046)),y),bri(sin(min(bri(add(div(x,x),x),aud(0.31295943,aud(x,x))),tan(x))),tan(0.9492328)))),aud(sin(y),aud(0.21456671,add(bri(y,div(mul(tan(add(y,y)),0.26504326),tan(sin(y)))),mul(y,sin(0.58931494)))))))),aud(0.5464945,pow(y,aud(cos(cos(pow(y,0.964658))),0.2199068)))),sin(pow(0.107978106,bri(add(y,add(tan(mul(min(sub(y,y),bri(x,aud(aud(add(0.8008337,y),pow(0.9699745,x)),max(aud(x,x),max(y,0.33831382))))),x)),0.36009717)),y)))));
    float g = tan(pow(min(pow(add(pow(x,y),x),div(cos(y),max(sub(add(pow(cos(x),0.7160039),add(y,min(x,0.026048422))),add(min(pow(min(x,sin(add(add(0.34540105,y),tan(y)))),bri(tan(tan(aud(x,y))),y)),x),bri(sin(min(bri(add(div(x,y),0.32819343),aud(0.6991024,aud(x,y))),tan(y))),tan(0.7280178)))),aud(sin(x),aud(y,add(bri(0.7390859,div(mul(tan(add(x,y)),y),tan(sin(y)))),mul(x,sin(y)))))))),aud(y,pow(x,aud(cos(cos(pow(x,y))),x)))),sin(pow(y,bri(add(y,add(tan(mul(min(sub(0.34540105,x),bri(x,aud(aud(add(x,y),pow(y,0.7656131)),max(aud(x,y),max(x,y))))),y)),y)),x)))));
    float b = tan(pow(min(pow(add(pow(x,y),y),div(cos(x),max(sub(add(pow(cos(0.9805982),x),add(x,min(0.7489519,0.08465958))),add(min(pow(min(y,sin(add(add(x,y),tan(y)))),bri(tan(tan(aud(y,y))),x)),0.002612114),bri(sin(min(bri(add(div(x,x),y),aud(0.45240784,aud(y,0.64415216))),tan(x))),tan(x)))),aud(sin(x),aud(0.13262796,add(bri(y,div(mul(tan(add(0.8241503,x)),0.29298973),tan(sin(y)))),mul(x,sin(0.8979006)))))))),aud(y,pow(x,aud(cos(cos(pow(0.4982772,y))),0.84431744)))),sin(pow(x,bri(add(x,add(tan(mul(min(sub(x,y),bri(y,aud(aud(add(x,y),pow(0.31340003,y)),max(aud(x,x),max(x,y))))),y)),0.19561577)),x)))));
    return vec3(r,g,b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);

    gl_FragColor = vec4(RGB.x, RGB.y, RGB.z, 1.0);
}
