/*
STEP 03 - MUTATION

Produces a random output and then mutates it.

Press mouse to mutate Individual.
Press a key to create a nnew random individual.

If machine has no camera, it is replaced by a placeholder image.

*/

import processing.sound.*;
import processing.video.*;

//Camera
Capture cam;
PImage inputImage;

//Sound
FFT fft;
SoundFile soundFile; //song fetched from youtube music library: Jeremy Blake - Cool Revenge
boolean muted = true;
int nBands = 512;
int soundIndex = 0;

//Odds of mutating nodes
float mutationRate = 0.3;
int maxTreeDepth = 15;

Individual individual;
int maxDepth = 15;
String[] fragShaderTemplateLines;
int shaderChangeLineStart;
Operation[] enabledOperations;



void setup() {
  size(940,940,P2D);
  
  //setup camera
  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    inputImage = loadImage("placeholder.jpg");
  } else {
    cam = new Capture(this, 1280, 720);
    cam.start();
  }
  
  //setup song
  fft = new FFT(this, nBands);
  soundFile = new SoundFile (this, "song.mp3");
  soundFile.loop();
  fft.input(soundFile);
  
  //load template shader
  fragShaderTemplateLines = loadStrings("fragShaderTemplate.glsl");
  
  //find line in the template that is to be changed
  shaderChangeLineStart = findLineToChangeInShader(fragShaderTemplateLines);
  
  //create array of operations i.e. function set
  enabledOperations = setupOperations();
  
  //create an individual
  individual = new Individual();
}

void draw() {
  //get camera feed if available
  setInputImage();
  
  //show individual while passing input information
  drawPhenotype(0, 0, width, height, individual.getShader(), getAudioSpectrum(), inputImage);
}

void setInputImage() {
  if (cam == null) return;
  if (cam.available() != true) return;

  cam.read();
  inputImage = cam;
}

void mouseReleased() {
  //mutate individual
  individual.mutate();
  println("Mutated Individual");
}

void keyPressed(){
  individual = new Individual();
}
