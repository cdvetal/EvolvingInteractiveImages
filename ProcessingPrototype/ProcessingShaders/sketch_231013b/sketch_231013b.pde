PShader shader;
PImage image;

void setup(){
  size(640, 360, P2D);
  frameRate(120);
  image = createImage(640, 360, RGB);;      
  
  String[] lines = loadStrings("shader.glsl");
  
  //lines[1] = "gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);";
  //saveStrings("data/shader.glsl", lines);
  
  shader = loadShader("shader.glsl");

  shader.set("resolution", width, height);
}

void draw(){
  shader(shader);
  shader.set("externalVal", map(sin((float)millis()/1000 * 1.2), -1, 1, 0, 1));
  image(image, 0, 0);
}
