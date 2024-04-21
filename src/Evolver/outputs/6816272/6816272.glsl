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

    return sum/(radius * 2);
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
    int varIndex = int(floor(x * nVariables));

    if(varIndex >= nVariables){
        varIndex = nVariables - 1;
    }

    return variables[varIndex];
}

vec3 generateRGB(float x, float y){
    float r = noi(y,pow((tan(x)/(mod((mod(y,mod(pow(bri(x,0.71955156),bri(x,0.0)),noi(var(cos((x-aud(y,(tan(y)*pow(noi(aud(y,var(0.23622537)),(sin((0.25265443+x))+(0.48851788/noi(x,y)))),min((((x+y)+sin(0.42930365))/x),0.5493629))))))),aud(x,y))))+(min(cos(pow(y,y)),0.0)/y)),bri(0.83754444,(((x*0.73491544)+y)/x)))*sin(sin(sin(noi(var(y),min(sin(y),sin(y)))))))),mod(max(mod(x,min(bri(x,x),0.86122066)),var(sin(max(y,y)))),min((var(y)*0.5316616),x))));
    float g = noi(0.6088319,pow((tan(y)/(mod((mod(y,mod(pow(bri(x,0.29474705),bri(x,x)),noi(var(cos((y-aud(y,(tan(0.50974077)*pow(noi(aud(x,var(x)),(sin((y+x))+(0.26541352/noi(0.61355567,0.17704386)))),min((((y+0.24682528)+sin(x))/0.6843971),y))))))),aud(x,x))))+(min(cos(pow(y,x)),y)/0.6747076)),bri(x,(((x*0.5797195)+0.21583271)/0.10649503)))*sin(sin(sin(noi(var(y),min(sin(0.72621506),sin(0.7364718)))))))),mod(max(mod(y,min(bri(0.14611244,x),x)),var(sin(max(0.54393554,x)))),min((var(x)*x),y))));
    float b = noi(0.6868524,pow((tan(y)/(mod((mod(0.5242592,mod(pow(bri(y,0.57719433),bri(x,y)),noi(var(cos((x-aud(y,(tan(0.7896137)*pow(noi(aud(x,var(y)),(sin((x+x))+(0.9119725/noi(x,x)))),min((((0.17853892+0.41053927)+sin(0.61853796))/x),y))))))),aud(0.77995795,x))))+(min(cos(pow(x,x)),y)/0.84702694)),bri(0.1319511,(((0.5556194*0.3211975)+y)/x)))*sin(sin(sin(noi(var(0.9456068),min(sin(0.09950638),sin(0.3024146)))))))),mod(max(mod(y,min(bri(y,0.28978533),y)),var(sin(max(0.6444871,x)))),min((var(y)*x),0.9723345))));
    return vec3(r,g,b);
}

void main() {
    vec2 coord = gl_FragCoord.xy;
    
    vec2 uv = coord / resolution.y;

    float x = uv.x;
    float y = uv.y;

    vec3 RGB = generateRGB(x, y);

    gl_FragColor = vec4(RGB.x, RGB.y, RGB.z, 1.0);
}
