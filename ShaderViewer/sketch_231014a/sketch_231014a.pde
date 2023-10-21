import java.util.*;

PShader[] shaders;
PImage shaderImage;

float minExternal = 0;
float maxExternal = 1;
float minSpeed = 0;
float maxSpeed = 1;

int shaderIndex = 0;

float feedbackDuration = 3;
float feedbackTimer = 0;

void setup() {
  frameRate(120);
  fullScreen(P2D);
  shaders = loadShaders();
  shaderImage = new PImage(width, height, RGB);
  applyShader();
}

void draw() {
  shaders[shaderIndex].set("externalVal", getExternalValue());
  image(shaderImage, 0, 0);
  showFeedback();
}

void showFeedback() {
  if(feedbackTimer > feedbackDuration) return;
  feedbackTimer += 1/frameRate;
  resetShader();
  
  PGraphics canvas = createGraphics(100, 50, P2D);

  canvas.beginDraw();

  canvas.fill(0);
  canvas.rect(0, 0, canvas.width, canvas.height);
  canvas.fill(255);
  canvas.text(minExternal + "\n" + maxExternal, 10, 20);

  canvas.endDraw();

  image(canvas, width - (canvas.width + 30), height - (canvas.height + 30));
  
  applyShader();
}

void applyShader(){
  shader(shaders[shaderIndex]);
}

void keyPressed() {
  if (key != CODED) return;

  if (keyCode == UP) {
    minExternal += 1;
    maxExternal += 1;
  } else if (keyCode == DOWN) {
    minExternal -= 1;
    maxExternal -= 1;
  }

  startFeedback();
}

void mousePressed() {
  if (mouseButton == LEFT) shaderIndex ++;
  else shaderIndex --;

  if (shaderIndex >= shaders.length) shaderIndex = 0;
  else if (shaderIndex < 0) shaderIndex = shaders.length - 1;

  applyShader();
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();

  float oldDiff = maxExternal - minExternal;
  float newDiff = 0;

  if (e > 0) {
    newDiff = oldDiff * 1.1;
  } else {
    newDiff = oldDiff * 0.9;
  }

  float toChange = (newDiff - oldDiff) / 2;

  minExternal -= toChange;
  maxExternal += toChange;

  startFeedback();
}

void startFeedback() {
  feedbackTimer = 0;

  println();
  println("min: " + minExternal);
  println("max: " + minExternal);
}

float getExternalValue() {
  float currentSpeed = map(mouseX, 0, width, minSpeed, maxSpeed);
  float toReturn;

  toReturn = map(sin((float)millis()/1000 * currentSpeed), -1, 1, minExternal, maxExternal);

  return toReturn;
}

PShader[] loadShaders() {
  String directory = "/shaders";

  File f = dataFile(directory);
  String[] names = f.list();
  Collections.shuffle(Arrays.asList(names));

  PShader[] shadersToReturn = new PShader[names.length];

  for (int i = 0; i < shadersToReturn.length; i++) {
    shadersToReturn[i] = loadShader(directory + "/" +names[i]);
  }

  return shadersToReturn;
}
