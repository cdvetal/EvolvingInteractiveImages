import java.util.*;

Individual[] individuals;
PImage shaderImage;

float minExternal = 0;
float maxExternal = 1;
float minSpeed = 0;
float maxSpeed = 1;

float currentSpeed;
float previousSpeed;

int individualIndex = 0;

boolean feedbackAlwaysEnabled = true;
float feedbackDuration = 3;
float feedbackTimer = 0;



void setup() {
  frameRate(120);
  fullScreen(P2D);
  individuals = loadIndividuals();
  shaderImage = new PImage(width, height, RGB);
  applyShader();
}

void draw() {
  float external = getExternalValue();
  individuals[individualIndex].shader.set("externalVal", external);
  image(shaderImage, 0, 0);
  showFeedback(external);
}

void showFeedback(float _external) {
  if(feedbackTimer > feedbackDuration && !feedbackAlwaysEnabled) return;
  
  feedbackTimer += 1/frameRate;
  resetShader();
  
  PGraphics canvas = createGraphics(130, 130); //P2D disbales shader while showing feedback

  canvas.beginDraw();

  canvas.noStroke();
  canvas.fill(0, 150);
  canvas.rect(0, 0, canvas.width, canvas.height);
  canvas.fill(255);
  canvas.text(individualIndex + "/" + individuals.length + ": " + individuals[individualIndex].file + "\n\n" + 
              "minE: " + minExternal + "\n" + 
              "maxE: " + maxExternal + "\n" +
              "currE: " + nf(_external, 0, 3) + "\n" +
              "speed: " + nf(currentSpeed, 0, 3) + "\n\n" + 
              _external, 10, 20);

  canvas.endDraw();

  image(canvas, width - (canvas.width + 30), height - (canvas.height + 30));
  
  applyShader();
}

void applyShader(){
  shader(individuals[individualIndex].shader);
}

void keyPressed() {
  if (key == 'f' || key == 'F') feedbackAlwaysEnabled = !feedbackAlwaysEnabled;
  
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
  if (mouseButton == LEFT) individualIndex ++;
  else individualIndex --;

  if (individualIndex >= individuals.length) individualIndex = 0;
  else if (individualIndex < 0) individualIndex = individuals.length - 1;

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
  println(individuals[individualIndex].file);
  println("min: " + minExternal);
  println("max: " + minExternal);
}

float getExternalValue() {
  currentSpeed = map(mouseX, 0, width, minSpeed, maxSpeed);
  float toReturn;

  toReturn = map(sin((float)millis()/1000 * currentSpeed), -1, 1, minExternal, maxExternal);
  
  if(currentSpeed != previousSpeed) startFeedback();
  
  previousSpeed = currentSpeed;

  return toReturn;
}

Individual[] loadIndividuals() {
  String directory = "/shaders";

  File f = dataFile(directory);
  String[] names = f.list();
  Collections.shuffle(Arrays.asList(names));

  Individual[] individualsToReturn = new Individual[names.length];

  for (int i = 0; i < names.length; i++) {
    PShader shader = loadShader(directory + "/" + names[i]);
    individualsToReturn[i] = new Individual(shader, names[i]);
  }

  return individualsToReturn;
}
