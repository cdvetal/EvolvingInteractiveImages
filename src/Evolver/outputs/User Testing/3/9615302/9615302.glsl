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
    float r = bri(sin(((y+y)+(((0.1633603+0.0070361495)+((((y+y)+(y+x))-(y+0.8994105))+((((x+0.93698)+y)+(y+0.058889866))*x)))-((((0.91153497+(0.61944795+0.40586042))+(y+0.69827306))-y)-((((0.23967469+y)+(0.67857295+0.5997952))+y)-((x+y)+(y+y))))))),max(max(((bri(tan((((y-x)/x)/cos((x-y)))),((((x+x)+(y+x))+(y+(x+0.35738868)))-(((x+x)-(x-0.22870666))+((x-0.33614254)+(y+0.36061463)))))*aul(((((x+0.19451219)+(x+y))-((0.5431482/0.9736689)-(0.6374241-x)))+((x+y)-(x+(y+x)))),((((y+0.56015944)+(0.8821301+x))-((y+y)*(0.23587453+x)))-(((0.6225965+y)+(0.34829128-0.122168034))+((x+x)+(x+y))))))*(x*((0.050628126+y)+(((x+x)-(0.81458527+y))+(((0.8188607+x)+0.12343097)+(x+0.92790055)))))),(max(((aul(((0.06495242-x)-(y*0.0)),((y*x)-(x+0.98838735)))-pow(((y+0.22161531)*(y+x)),cos((y/0.8284689))))+((((y+x)+(y+x))+((0.58014464+0.1980502)-(x+0.7379973)))-(((x+0.5982842)+(x+0.5674411))*((x+y)+(y+y))))),sin(((aul((y+y),(0.23675962+y))*((0.6634603*y)+(x+0.08836915)))+(((y+0.82642955)+x)+((x+x)+(0.7476212+y))))))-(y-((((x+0.60523957)+(y+0.5122293))+(0.7486945+(y+0.5503478)))+((x+(x+(x+y)))+x))))),min((tan((((sin((y+x))+(y+(0.7232802+x)))+(((0.35512924+x)+(x+y))+((x+x)+(x-0.5278936))))+((0.3053831-x)+(((0.29924512+0.35787874)+(0.66850966+x))+((y+0.21468723)-(y+0.98486584))))))+sin((((((0.46027645+0.6691328)+(y+x))*((0.0019304752+x)+x))-(((0.19572079+0.08393633)+0.9616513)+((0.7470256+x)+(y+x))))+((((y+0.61402774)-(y+x))+(y+(0.1686194+x)))+(((0.7634722+y)+(0.9611485+y))+((0.10818422+0.23292214)+(y+y))))))),var(aul(pow(max((((0.7146838+x)+(x+x))-((x+y)+(0.5238882+x))),(((0.31651813+0.087462544)+(y+y))/((0.17938149+x)+(y-0.0)))),((((x+x)-(x+x))*((y+y)+(y+x)))*(((y+0.77661324)-0.51953816)+((0.7400025+y)+(y+y))))),((x+(y+0.27117437))+(x+(x+x))))))));
    float g = bri(sin(((y+y)+(((x+0.38691276)+((((x+0.42661053)+(y+0.3086434))-(0.03377348+y))+((((0.8110419+y)+0.79260635)+(x+x))*x)))-((((y+(x+x))+(y+0.4016651))-x)-((((y+x)+(x+y))+y)-((y+x)+(x+y))))))),max(max(((bri(tan((((0.62152123-0.52398044)/0.28561467)/cos((x-0.7540142)))),((((x+0.31747612)+(y+y))+(y+(y+0.8301765)))-(((x+x)-(y-x))+((y-0.8378656)+(0.42914593+x)))))*aul(((((x+y)+(y+y))-((x/y)-(x-0.16174775)))+((x+0.60692275)-(0.6926129+(y+y)))),((((x+0.37021762)+(x+0.17676777))-((y+y)*(0.03597182+y)))-(((0.32207897+x)+(y-y))+((x+y)+(0.9741887+y))))))*(0.16519994*((x+y)+(((0.9255395+x)-(y+0.119047344))+(((0.6128783+y)+x)+(x+x)))))),(max(((aul(((y-y)-(y*0.7111286)),((0.8661913*y)-(x+0.6095197)))-pow(((y+y)*(y+0.042267814)),cos((x/x))))+((((y+y)+(x+y))+((x+x)-(0.099773526+y)))-(((x+y)+(y+y))*((x+x)+(y+0.2586851))))),sin(((aul((x+0.8886932),(y+y))*((x*0.61641455)+(y+y)))+(((x+x)+x)+((y+x)+(y+y))))))-(0.64008254-((((0.61716664+0.32586962)+(0.8107145+y))+(0.0052616+(x+y)))+((y+(x+(x+0.54181856)))+0.66179895))))),min((tan((((sin((y+x))+(y+(y+y)))+(((0.022636056+x)+(x+y))+((x+y)+(0.27788493-y))))+((0.69816524-0.43948084)+(((0.23681313+x)+(0.58614314+y))+((y+0.8013924)-(x+x))))))+sin((((((y+y)+(0.94346255+x))*((y+0.6312216)+0.35551268))-(((x+x)+y)+((x+x)+(0.3240922+y))))+((((x+x)-(y+0.31403285))+(x+(x+y)))+(((x+0.27991337)+(y+0.8869432))+((x+x)+(y+0.6369467))))))),var(aul(pow(max((((y+0.37481084)+(x+y))-((0.5614316+y)+(x+0.47837538))),(((y+x)+(y+x))/((y+0.99289745)+(0.17040059-y)))),((((0.5805341+x)-(x+x))*((x+x)+(0.049408257+x)))*(((0.040780842+y)-y)+((x+x)+(x+y))))),((x+(y+y))+(y+(y+y))))))));
    float b = bri(sin(((0.4465506+y)+(((x+0.50669396)+((((0.4723345+0.62871104)+(y+y))-(y+0.3106978))+((((0.74007744+x)+0.74231637)+(0.24439162+x))*0.41362542)))-((((y+(x+x))+(y+y))-x)-((((y+0.9525082)+(0.19018185+0.29692018))+y)-((y+y)+(0.41311973+x))))))),max(max(((bri(tan((((y-y)/0.7533939)/cos((0.84228814-x)))),((((x+0.82552135)+(y+0.110625744))+(y+(y+x)))-(((0.029958665+x)-(y-0.108507514))+((x-0.6656153)+(y+y)))))*aul(((((y+0.3661682)+(y+0.7390717))-((x/0.97775733)-(0.968617-x)))+((y+y)-(y+(0.32604092+y)))),((((x+x)+(x+x))-((y+0.49538773)*(0.6178563+x)))-(((0.15003258+y)+(x-y))+((0.36230677+y)+(x+y))))))*(y*((0.55903816+x)+(((x+x)-(x+y))+(((0.6703516+y)+0.20170927)+(x+y)))))),(max(((aul(((y-x)-(0.30378857*0.0)),((x*y)-(0.7499244+y)))-pow(((y+y)*(x+x)),cos((y/x))))+((((y+x)+(y+x))+((x+y)-(x+y)))-(((x+y)+(x+y))*((y+y)+(y+0.6460002))))),sin(((aul((y+x),(y+y))*((x*y)+(y+0.8204067)))+(((0.9632486+x)+x)+((y+y)+(x+0.20776987))))))-(0.8416039-((((x+x)+(y+x))+(y+(y+0.72950417)))+((y+(x+(x+0.7866971)))+0.68443805))))),min((tan((((sin((0.11333674+y))+(y+(x+0.42197442)))+(((y+0.63914716)+(y+x))+((y+x)+(0.5143005-0.23964518))))+((x-x)+(((0.61368334+y)+(y+0.24287099))+((x+0.26058912)-(0.5242442+x))))))+sin((((((0.56309295+x)+(y+y))*((y+y)+0.30609977))-(((0.3201263+y)+y)+((0.091457+0.9175635)+(y+y))))+((((x+y)-(0.29199922+0.3311659))+(y+(x+0.32123584)))+(((x+x)+(0.9895588+0.47655863))+((y+x)+(y+x))))))),var(aul(pow(max((((0.6614758+y)+(0.21173286+y))-((0.37813246+x)+(x+x))),(((0.52136064+y)+(y+y))/((x+x)+(x-y)))),((((y+y)-(0.46325058+x))*((x+y)+(0.5322579+x)))*(((x+0.28260863)-y)+((y+0.22431922)+(0.19221666+0.046483755))))),((0.23207939+(y+y))+(0.70452744+(0.8382899+0.7790653))))))));
    return vec3(r,g,b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);

    gl_FragColor = vec4(RGB.x, RGB.y, RGB.z, 1.0);
}
