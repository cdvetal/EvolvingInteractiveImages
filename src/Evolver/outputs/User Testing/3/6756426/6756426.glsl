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
    float r = max(sin((((((x+x)+((y+0.85377806)+(0.7318926+x)))+((0.92793256+x)+0.48466337))-(0.38174343-0.35302484))+(((((x+x)+0.5951176)+(x-y))+((((y+0.32704067)+((0.049559712+y)-(0.5923734+0.7988173)))+(((x+x)+(y+0.23221225))-((0.45484686+0.55940187)+(y+y))))+((((x+0.29784983)+(0.791723+0.9818305))+(cos(y)+(0.79101527+y)))+((0.50092363+0.02608484)+(y+(y+y))))))-(((((0.44744128+(y+y))+0.6153753)+(((0.046694756+y)+x)+(y+0.74247605)))+((y+y)+x))-(((((0.38126367+y)+(0.51514953+0.7092768))+((x-x)+(y-x)))+(((0.74555075+0.73639584)-(0.07596141-y))+((0.6355097+0.57800406)+(x+y))))-(((y+y)-(0.36020404+x))+((y+0.07194328)+(y+(y+x))))))))),bri(max(((min(tan((((y-x)/(x/0.47718555))-cos((x+y)))),((((x+0.29854798)-(y+0.0))+((y+y)+(x*0.2503516)))+(((x-x)*(x+0.0))+((0.9876264+0.101807065)+(0.3309426+x)))))-var(((((y+0.48945254)+(x+y))+((0.46408087-0.72453904)+(0.56815284+x)))+(((y+y)+(x+x))-((y+0.85336626)-0.08707881)))))*(((x+x)+((0.9141281+0.2035768)+(y+(x+0.8650126))))-((x+(((0.15503651+0.9183805)+y)-x))+((((x+0.76096666)+(y-y))+(0.6520189-(y+x)))+((0.6261025+0.3511142)+(0.7289071+(x+x))))))),(bri(((max(((0.14002451+x)*(y-0.0)),((y+x)+(x+0.82067716)))+pow(((y+0.24604923)+(y+x)),sin((x/x))))+((((y+y)+(y+x))+((0.37493867+0.43593335)/(x-x)))-(((y+0.78953815)+(x+0.5305952))-((x-y)+(y+y))))),cos(((max((y+y),(0.0+0.56337804))-((0.8742162-y)*(x+0.16811661)))-(((y+0.65831906)+x)+((0.88675594-x)+(0.51445895+y))))))/(((((0.40265375+y)+(x-(y+y)))+((y+x)+(x+(x+y))))-(((0.5861469+(y+0.6836205))+((0.9734763+x)+(0.31180197+0.9217497)))+((x+(0.31950492+y))*y)))+(((((y+0.19986767)+(x+y))+(y+0.57344663))+((y+x)-((0.53427637+y)-0.71578)))+((x+(x+y))+((0.3615269+x)+y)))))),bri((tan((((sin((y+0.9409003))+((y+x)+(0.5865115+x)))+(((0.083461404-x)-(x+0.2937267))-((x+0.15117037)+(x-0.5278936))))+((((y+x)+y)+0.38021493)+(((x+y)-x)-((x+x)+(y+y))))))-cos((((((0.47620815+0.58111334)-(y+0.6342189))+((y+y)+(y+0.41069788)))+(((y+0.5823893)-(x-x))-((y/0.062717915)+(x+0.55945534))))-(((0.051159203+0.6314249)+((0.1276955+y)+(y+0.5466703)))-((y+x)-((x+y)+(x-y))))))),sin(aul(pow(pow(tan((x/max(0.0,0.0))),(((0.31651813-0.14399023)+(x+y))+((0.38037407*x)-(y*0.3646065)))),((((0.25673336+0.3087809)+(y+0.73498833))+(y+(x+y)))/(((y+0.77616453)+(x+x))+((y+y)+x)))),((((x+(x+y))+0.88737166)+(x-((x+0.93240684)+(0.11194593+0.71720964))))+((((y+y)+(0.029315472+x))+((x+0.675134)+0.32436883))+(((0.051495552+y)+(0.71397007+y))+((x+y)+y)))))))));
    float g = max(sin((((((y+0.60959584)+((y+0.60467505)+(x+0.8052873)))+((y+0.8651644)+y))-(y-0.7021444))+(((((y+0.24300152)+0.70232946)+(0.706148-y))+((((y+x)+((0.6694021+y)-(x+x)))+(((x+0.528525)+(x+0.43848056))-((y+0.4329486)+(y+y))))+((((0.74670964+x)+(y+y))+(cos(0.45760256)+(x+y)))+((y+y)+(x+(0.08519876+y))))))-(((((0.8052004+(x+0.23980755))+y)+(((x+0.29691893)+y)+(0.87957+y)))+((y+0.13601965)+y))-(((((y+y)+(y+y))+((0.55421984-y)+(y-0.10557139)))+(((0.6771886+0.44985062)-(y-y))+((y+y)+(0.23290336+x))))-(((0.051537216+x)-(x+y))+((y+y)+(0.03125882+(0.24831998+y))))))))),bri(max(((min(tan((((0.34638-0.49171805)/(0.9078202/x))-cos((x+x)))),((((x+0.082057625)-(0.34531772+x))+((y+0.4040873)+(y*0.35200602)))+(((x-x)*(y+x))+((y+0.8179811)+(0.87617165+0.984746)))))-var(((((y+x)+(y+y))+((x-y)+(x+0.3555799)))+(((y+0.4208604)+(x+y))-((x+y)-x)))))*(((0.6221323+x)+((0.05756432+x)+(y+(0.5952494+0.13770854))))-((0.484241+(((0.538942+0.9252929)+0.922399)-x))+((((x+y)+(x-x))+(x-(y+x)))+((y+0.23436284)+(y+(x+y))))))),(bri(((max(((y+y)*(y-0.84400165)),((0.8255416+y)+(x+0.6095197)))+pow(((x+y)+(y+0.0)),sin((y/y))))+((((y+y)+(0.90988094+y))+((x+x)/(0.28427288-y)))-(((y+y)+(y+x))-((y-x)+(y+0.2586851))))),cos(((max((0.980459+x),(0.26769912+y))-((x-0.88030833)*(y+y)))-(((x+x)+x)+((x-0.623816)+(y+y))))))/(((((x+x)+(x-(x+0.61227036)))+((y+0.26741016)+(y+(0.27116847+y))))-(((x+(0.9692699+x))+((0.44475156+x)+(0.6846966+y)))+((y+(y+0.23945671))*x)))+(((((x+x)+(y+0.87751454))+(y+y))+((x+x)-((x+x)-0.40672606)))+((y+(0.41990966+0.77837384))+((x+x)+0.12408006)))))),bri((tan((((sin((0.7173346+0.01714164))+((0.6272544+0.40858555)+(0.68601537+y)))+(((0.021878019-x)-(x+0.24786276))-((x+y)+(0.02134037-y))))+((((y+x)+x)+0.73699594)+(((0.06222546+x)-0.8705038)-((0.21163398+y)+(x+x))))))-cos((((((y+y)-(x+x))+((0.37587798+x)+(x+0.460877)))+(((x+0.23753038)-(x-y))-((0.0/y)+(x+0.25298256))))-(((x+y)+((x+0.79463124)+(0.01755023+0.66466963)))-((y+0.45635498)-((x+y)+(x-x))))))),sin(aul(pow(pow(tan((0.50963116/max(0.0,0.0))),(((y-x)+(y+x))+((x*x)-(0.17040059*y)))),((((0.58660376+x)+(x+y))+(y+(0.09851664+x)))/(((y+0.48569387)+(x+x))+((0.20173864+0.89266646)+y)))),((((x+(y+x))+y)+(0.83375216-((y+y)+(x+y))))+((((x+x)+(x+0.09596175))+((x+0.47519678)+x))+(((y+x)+(y+x))+((y+x)+y)))))))));
    float b = max(sin((((((y+0.9812835)+((0.010301828+y)+(0.28120673+x)))+((y+0.16592073)+x))-(0.2337395-y))+(((((0.80903506+x)+x)+(y-y))+((((x+y)+((x+y)-(0.2685737+x)))+(((0.42047042+y)+(0.100155294+0.35890567))-((0.24089402+y)+(x+0.5810979))))+((((y+x)+(x+x))+(cos(0.89970124)+(x+x)))+((y+x)+(y+(x+x))))))-(((((x+(y+0.4084679))+y)+(((0.044204593+y)+0.9438227)+(y+y)))+((0.7725284+y)+x))-(((((x+0.6519917)+(y+0.3264761))+((y-0.2016803)+(y-0.32114857)))+(((x+y)-(x-x))+((y+y)+(0.07519048+0.6071484))))-(((y+y)-(0.05990535+y))+((0.8176083+y)+(x+(0.8238555+0.7210561))))))))),bri(max(((min(tan((((y-y)/(0.7922977/0.3803991))-cos((0.9834382+x)))),((((x+x)-(y+y))+((x+0.23807287)+(y*x)))+(((0.029958665-x)*(y+0.469102))+((x+0.27823552)+(x+y)))))-var(((((x+x)+(y+0.8302109))+((x-0.9336478)+(0.968617+x)))+(((y+y)+(0.40090317+0.75360864))-((y+0.577093)-0.05676502)))))*(((x+x)+((y+x)+(x+(x+x))))-((y+(((0.17544132+x)+0.78490806)-0.63300276))+((((0.9271072+x)+(0.8975721-x))+(0.51793957-(0.493039+x)))+((x+x)+(y+(x+y))))))),(bri(((max(((y+x)*(0.38131598-0.0)),((y+y)+(0.31738493+y)))+pow(((x+y)+(x+x)),sin((y/x))))+((((y+x)+(y+0.61087817))+((0.9787785+y)/(x-y)))-(((x+y)+(x+y))-((x-y)+(y+0.6460002))))),cos(((max((x+x),(x+y))-((x-y)*(y+0.577066)))-(((0.9222876+x)+x)+((y-y)+(x+0.26046792))))))/(((((0.59431404+x)+(x-(0.786961+y)))+((x+0.287028)+(x+(y+x))))-(((0.93062836+(x+x))+((y+y)+(x+y)))+((0.2919774+(y+y))*0.041990697)))+(((((x+0.69412744)+(x+x))+(y+x))+((0.9457764+y)-((0.38882732+0.23274904)-y)))+((x+(y+0.10243821))+((0.5897963+x)+y)))))),bri((tan((((sin((0.822538+y))+((x+x)+(x+y)))+(((y-0.8548347)-(0.1456958+x))-((y+y)+(0.43380082-0.23964518))))+((((y+0.3083015)+y)+0.47350055)+(((0.1320371+y)-0.52232015)-((0.6334943+0.8769969)+(y+x))))))-cos((((((0.2538818+0.9306271)-(0.8243989+y))+((0.053356826+y)+(0.5901305+0.41580904)))+(((y+y)-(y-x))-((0.9780119/0.8264233)+(y+0.42247242))))-(((x+0.029934883)+((0.2727744+x)+(y+y)))-((0.12651962+y)-((y+0.71781045)+(x-x))))))),sin(aul(pow(pow(tan((x/max(0.0,0.0))),(((0.51698595-y)+(x+y))+((x*x)-(x*y)))),((((y+0.6004434)+(0.7677326+y))+(0.697507+(y+x)))/(((y+0.38747934)+(0.812341+x))+((y+x)+y)))),((((0.05289191+(y+0.5253686))+x)+(y-((x+y)+(0.07838434+0.88618165))))+((((0.56402385+0.421946)+(x+y))+((0.84271556+x)+x))+(((0.95296115+0.6021332)+(x+x))+((x+y)+0.425251)))))))));
    return vec3(r,g,b);
}

void main() {
    vec3 RGB = generateRGB(uv.x, uv.y);

    gl_FragColor = vec4(RGB.x, RGB.y, RGB.z, 1.0);
}
