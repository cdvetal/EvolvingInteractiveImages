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
    float r = (max(bri(cos(((sin(y)-x)+(bri(y,x)/min(0.688716,y)))),cos((max(sin(0.10564077),cos(0.12054545))+max(sin(x),max(0.6392686,x))))),max(cos((((x*0.46282214)-min(x,0.6484521))*pow(max(0.7760335,0.74860275),tan(x)))),bri(min(x,(sin(y)*mod(0.0635342,x))),((min(0.9571611,x)-mod(y,x))-sin(0.5000008)))))+((max(pow(pow(tan(x),(x*x)),min(sin(0.22070593),(y+x))),(max(pow(x,0.7652153),sin(y))+(cos(0.38334846)/mod(y,x))))-0.5956376)-cos(min(bri(max((x/0.08845943),x),pow(cos(0.19134879),pow(x,x))),pow(x,pow(tan(y),bri(y,x)))))));
    float g = (max(bri(cos(((sin(x)-y)+(bri(x,0.31978905)/min(x,0.032185614)))),cos((max(sin(y),cos(0.77060026))+max(sin(x),max(0.91975164,x))))),max(cos((((y*x)-min(y,y))*pow(max(x,x),tan(0.46964228)))),bri(min(y,(sin(0.72995245)*mod(x,0.75416636))),((min(y,x)-mod(0.63293713,y))-sin(0.7638173)))))+((max(pow(pow(tan(y),(y*y)),min(sin(x),(y+x))),(max(pow(y,y),sin(x))+(cos(0.1158514)/mod(y,y))))-x)-cos(min(bri(max((y/x),0.33475453),pow(cos(x),pow(y,0.65717804))),pow(x,pow(tan(0.7965011),bri(y,y)))))));
    float b = (max(bri(cos(((sin(y)-y)+(bri(0.4095869,0.87738025)/min(0.15269709,y)))),cos((max(sin(x),cos(0.39244026))+max(sin(y),max(0.6962691,x))))),max(cos((((0.13771695*0.64813864)-min(0.1353516,y))*pow(max(y,x),tan(y)))),bri(min(0.6711799,(sin(y)*mod(x,y))),((min(x,y)-mod(x,0.78228235))-sin(y)))))+((max(pow(pow(tan(x),(0.74898684*0.7437726)),min(sin(x),(y+y))),(max(pow(y,y),sin(x))+(cos(x)/mod(0.6909562,y))))-x)-cos(min(bri(max((y/y),x),pow(cos(0.4154992),pow(0.89595026,0.39124346))),pow(0.41737765,pow(tan(x),bri(0.7496581,x)))))));
    return vec3(r,g,b);
}

void main() {
    vec2 uv = gl_FragCoord.xy / resolution;

    vec3 RGB = generateRGB(uv.x, uv.y);

    gl_FragColor = vec4(RGB.x, RGB.y, RGB.z, 1.0);
}
