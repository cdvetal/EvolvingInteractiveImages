/*
STEP 04 - RECOMBINATION

Produces two random individuals which recombine into a new one.

Press mouse to create recombination.

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

Individual parentA;
Individual parentB;
Individual[] children;
int nChildren = 5;

int maxTreeDepth = 15;
String[] fragShaderTemplateLines;
int shaderChangeLineStart;
Operation[] enabledOperations;

float childrenW, childrenY, childrenGap;

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
  parentA = new Individual("parentA");
  parentB = new Individual("parentB");
  
  childrenW = width/(nChildren + (float)1);
  childrenY = height/2 + (height/2 - childrenW) / (float)2;
  childrenGap = childrenW/(nChildren + (float)1);
}

void draw() {
  //get camera feed if available
  setInputImage();
  
  //show individual while passing input information
  drawPhenotype(0, 0, width/2, height/2, parentA.getShader(), getAudioSpectrum(), inputImage);
  drawPhenotype(width/2, 0, width/2, height/2, parentB.getShader(), getAudioSpectrum(), inputImage);
  if(children != null && children.length > 0){
    float currentX = childrenGap;
    for(int i = 0; i < children.length; i++){
      drawPhenotype(currentX, childrenY, childrenW, childrenW, children[i].getShader(), getAudioSpectrum(), inputImage);
      currentX += childrenGap + childrenW;
    }
  }
}

void setInputImage() {
  if (cam == null) return;
  if (cam.available() != true) return;

  cam.read();
  inputImage = cam;
}

void mouseReleased() {
  //create individual
  children = new Individual[nChildren];
  for(int i = 0; i < children.length; i++){
    String name = "child" + i;
    if(random(1) > 0.5) children[i] = getRecombination(parentA, parentB, name); 
    else children[i] = getRecombination(parentB, parentA, name); 
  }
}
