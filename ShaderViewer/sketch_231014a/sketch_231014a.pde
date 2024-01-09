import java.util.*;
import processing.sound.*;
import processing.video.*;

Capture cam;
PImage exampleImage;

Individual[] individuals;
PImage shaderImage;

float minExternal = 0;
float maxExternal = 1;
float minSpeed = 0;
float maxSpeed = 1;

boolean externalEnabled = true;

FFT fft;
SoundFile[] soundFiles;
int nBands = 512;
int soundIndex = 0;
boolean songPlaying = true;

float currentSpeed;
float previousSpeed;

int individualIndex = 0;

boolean feedbackAlwaysEnabled = false;
float feedbackDuration = 3;
float feedbackTimer = 0;

void setup() {
  frameRate(100);
  fullScreen(P2D);

  individuals = loadIndividuals();
  shaderImage = new PImage(width, height, RGB);
  applyShader();
}

void draw() {
  if (frameCount ==1) {
    //crashes if done in setup due to taking too long
    fft = new FFT(this, nBands);
    soundFiles = loadSongs();
    changeSong();

    String[] cameras = Capture.list();
    if (cameras.length == 0) {
      exampleImage = loadImage("shells.jpg");
    } else {
      println(cameras.length);
      cam = new Capture(this, 1280, 720);
      cam.start();
    }
  }
  if (cam != null && cam.available() == true) {
    cam.read();
    individuals[individualIndex].shader.set("image", cam);
  } else {
    individuals[individualIndex].shader.set("image", exampleImage);
  }
  float external = getExternalValue();
  float[] audioSpectrum = getAudioSpectrum();
  if(externalEnabled) individuals[individualIndex].shader.set("externalVal", external);
  individuals[individualIndex].shader.set("audioSpectrum", audioSpectrum);
  image(shaderImage, 0, 0);
  showFeedback(external);
}

void showFeedback(float _external) {
  if (feedbackTimer > feedbackDuration && !feedbackAlwaysEnabled) return;

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

void applyShader() {
  shader(individuals[individualIndex].shader);
}

void resetParameters() {
  minExternal = 0;
  maxExternal = 1;

  startFeedback();
}

void keyPressed() {
  if (key == 'f' || key == 'F') feedbackAlwaysEnabled = !feedbackAlwaysEnabled;
  if (key == 'r' || key == 'R') resetParameters();
  if (key == 'm' || key == 'M') changeSong();
  if (key == 'a' || key == 'A') muteSong();
  if (key == 'e' || key == 'E') exportImage();
  if (key == ' ') externalEnabled = !externalEnabled;

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
}

float getExternalValue() {
  currentSpeed = map(mouseX, 0, width, minSpeed, maxSpeed);
  float toReturn;

  toReturn = map(sin((float)millis()/1000 * currentSpeed), -1, 1, minExternal, maxExternal);

  if (currentSpeed != previousSpeed) startFeedback();

  previousSpeed = currentSpeed;

  return toReturn;
}

float[] getAudioSpectrum() {
  float[] spectrum = new float[nBands];
  fft.analyze(spectrum);
  return spectrum;
}

PImage getInputImage(){
  if (cam != null && cam.available() == true) {
    cam.read();
    return cam;
  }

  return exampleImage;
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

void changeSong() {
  soundFiles[soundIndex].stop();
  soundIndex ++;

  if (soundIndex >= soundFiles.length) soundIndex = 0;

  soundFiles[soundIndex].loop();
  fft.input(soundFiles[soundIndex]);
}

void muteSong() {
  if(songPlaying) soundFiles[soundIndex].stop();
  else soundFiles[soundIndex].loop();
  
  songPlaying =! songPlaying;
}

SoundFile[] loadSongs() {
  String directory = sketchPath("music/");

  File f = dataFile(directory);
  String[] names = f.list();

  SoundFile[] toReturn = new SoundFile[names.length];

  for (int i = 0; i < toReturn.length; i++)
  {
    toReturn[i] = new SoundFile(this, directory + names[i]);
  }

  return toReturn;
}

void exportImage(){
  String fileName = individuals[individualIndex].file + millis() + ".png";
  
  String outputPath = sketchPath("outputs/" + individuals[individualIndex].file + "/");
  
  PImage image = individuals[individualIndex].getPhenotype(2100, 1920, getExternalValue(), getAudioSpectrum(), getInputImage());
  image.save(outputPath + fileName);
  
  println("exported image to:" + outputPath);
}
