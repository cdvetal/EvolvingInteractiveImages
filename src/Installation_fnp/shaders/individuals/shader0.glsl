in vec4 gl_FragCoord;

uniform vec2 resolution;
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
    float r = min(max(mod(pow(max((pow(x,y)/(0.7519464/x)),cos(tan(0.82291746))),(bri(y,min(y,y))-tan((x-0.107560515)))),sin(bri(max(pow(0.43550205,x),tan(y)),max((y+y),(y/y))))),bri((sin(bri((x*x),x))-cos(tan((x/0.16542435)))),(bri((y*(y+x)),x)-sin(sin(cos(0.24795502)))))),pow(min(bri((x*x),mod(y,bri(x,(x-0.44332302)))),cos((pow(pow(x,y),(y*0.09547502))/pow(sin(0.9863114),(y/y))))),mod((tan((max(y,y)*(y-0.70909005)))/0.50960344),mod(((min(x,0.036829054)*0.062518)/0.37249196),max(min(x,min(x,0.15275663)),sin(cos(0.892902)))))));
    float g = min(max(mod(pow(max((pow(y,y)/(y/y)),cos(tan(y))),(bri(y,min(0.4098056,y))-tan((x-x)))),sin(bri(max(pow(0.6952572,y),tan(y)),max((x+0.9742786),(0.87715083/y))))),bri((sin(bri((x*0.71047354),y))-cos(tan((0.4898615/x)))),(bri((y*(y+0.36192888)),0.5242789)-sin(sin(cos(y)))))),pow(min(bri((x*x),mod(x,bri(0.6592362,(x-y)))),cos((pow(pow(0.2839322,x),(x*x))/pow(sin(y),(y/0.87825215))))),mod((tan((max(x,0.7400889)*(x-y)))/y),mod(((min(y,y)*0.62205595)/x),max(min(0.2189523,min(x,y)),sin(cos(y)))))));
    float b = min(max(mod(pow(max((pow(0.16995353,y)/(0.56105447/y)),cos(tan(x))),(bri(0.7829359,min(x,y))-tan((y-0.17447233)))),sin(bri(max(pow(0.7983915,x),tan(y)),max((x+0.5967863),(0.8827801/y))))),bri((sin(bri((x*0.2615109),0.8012277))-cos(tan((0.51526505/x)))),(bri((y*(0.025411606+y)),x)-sin(sin(cos(0.23825759)))))),pow(min(bri((x*x),mod(y,bri(y,(x-y)))),cos((pow(pow(x,x),(y*0.21785724))/pow(sin(x),(y/0.6385533))))),mod((tan((max(y,0.22133338)*(y-y)))/0.87886494),mod(((min(y,x)*0.32950294)/x),max(min(0.3558948,min(0.29605114,y)),sin(cos(0.59307665)))))));
    return vec3(r,g,b);
}

void main() {
    vec2 uv = gl_FragCoord.xy / resolution;

    vec3 RGB = generateRGB(uv.x, uv.y);

    gl_FragColor = vec4(RGB.x, RGB.y, RGB.z, 1.0);
}
