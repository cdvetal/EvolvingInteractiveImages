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
    float r = pow(max(y,x),add(add(pow(y,add(max(sin(x),0.44934845),min(max(sin(0.16139555),add(pow(0.18540525,bri(bri(0.63119125,div(x,bri(y,div(x,y)))),sin(x))),y)),min(0.45264912,tan(bri(cos(bri(aud(y,sin(tan(y))),mul(bri(sub(y,x),max(y,y)),cos(sub(y,y))))),y)))))),y),sin(pow(add(bri(sub(mul(sub(0.24454689,x),min(x,y)),aud(0.6538689,mul(tan(sub(div(mul(bri(0.7980819,x),aud(0.7895479,x)),min(bri(x,y),bri(y,x))),div(max(min(x,x),0.30416727),bri(min(x,y),max(x,0.7487385))))),min(x,x)))),0.8930106),y),y))));
    float g = pow(max(y,0.8223839),add(add(pow(x,add(max(sin(0.977942),x),min(max(sin(x),add(pow(x,bri(bri(0.14748454,div(x,bri(x,div(y,0.7493782)))),sin(0.606967))),y)),min(0.65063214,tan(bri(cos(bri(aud(y,sin(tan(y))),mul(bri(sub(0.7090137,x),max(0.8296094,y)),cos(sub(y,x))))),0.9101906)))))),y),sin(pow(add(bri(sub(mul(sub(x,0.9557524),min(0.2522502,x)),aud(x,mul(tan(sub(div(mul(bri(x,y),aud(y,x)),min(bri(0.266721,x),bri(y,x))),div(max(min(x,y),0.3782401),bri(min(0.7606182,x),max(y,x))))),min(x,y)))),y),0.53210163),y))));
    float b = pow(max(y,y),add(add(pow(y,add(max(sin(y),y),min(max(sin(0.11574745),add(pow(y,bri(bri(x,div(0.70164967,bri(0.49199033,div(0.60856295,0.74793196)))),sin(x))),0.5582807)),min(x,tan(bri(cos(bri(aud(x,sin(tan(0.23317862))),mul(bri(sub(0.48097348,0.9591179),max(0.53911567,x)),cos(sub(y,y))))),y)))))),y),sin(pow(add(bri(sub(mul(sub(x,y),min(y,y)),aud(0.93266773,mul(tan(sub(div(mul(bri(x,x),aud(y,y)),min(bri(x,x),bri(x,y))),div(max(min(x,0.38498926),x),bri(min(0.954257,0.40080786),max(0.49922395,y))))),min(0.95080566,x)))),x),0.8280399),y))));
    return vec3(r,g,b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);

    gl_FragColor = vec4(RGB.x, RGB.y, RGB.z, 1.0);
}
