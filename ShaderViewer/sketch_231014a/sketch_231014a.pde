import java.util.*;

PShader[] shaders;
PImage shaderImage;

float minExternal = 0.001;
float maxExternal = 0.999;
float minSpeed = .01;
float maxSpeed = 1;

int shaderIndex = 0;

void setup(){
  fullScreen(P2D);
  shaders = loadShaders();
  shaderImage = new PImage(width, height, RGB);
  shader(shaders[shaderIndex]);
}

void draw(){
  float currentSpeed = map(mouseX, 0, width, minSpeed, maxSpeed);
  shaders[shaderIndex].set("externalVal", getExternalValue(currentSpeed));
  image(shaderImage, 0, 0);
}

void mousePressed(){
  if (mouseButton == LEFT) shaderIndex ++;
  else shaderIndex --;
  
  if(shaderIndex >= shaders.length) shaderIndex = 0;
  else if (shaderIndex < 0) shaderIndex = shaders.length - 1;
  
  shader(shaders[shaderIndex]);
}

float getExternalValue(float _speed) {
  float toReturn;

  toReturn = map(sin((float)millis()/1000 * _speed), -1, 1, minExternal, maxExternal);

  return toReturn;
}

PShader[] loadShaders(){
  String directory = "/shaders";
  
  File f = dataFile(directory);
  String[] names = f.list();
  Collections.shuffle(Arrays.asList(names));
  
  PShader[] shadersToReturn = new PShader[names.length];
  
  for(int i = 0; i < shadersToReturn.length; i++){
    shadersToReturn[i] = loadShader(directory + "/" +names[i]);
  }
  
  return shadersToReturn;
}
