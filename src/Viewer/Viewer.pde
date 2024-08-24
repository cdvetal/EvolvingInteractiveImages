/*
Using Voice Meeter Banana and VB-Cables to route pc audio to Processing
 */

import java.util.*;
import processing.sound.*;
import processing.video.*;

Capture cam;
PImage inputImage;

AudioIn inputSound;
Amplitude soundAmplitude;

PImage shaderImage;

boolean externalEnabled = true;

//Export
int imageExportResolution = 1920;
PGraphics exportCanvas;

//Sound
FFT fft;
SoundFile[] soundFiles;
int nBands = 512;
int soundIndex = 0;
boolean songPlaying = true;

boolean showingSettings = true;

IndividualScreen individualScreen;
VariablesManager variablesManager;
SettingsScreen settingsScreen;

int gap = 24;

void setup() {
  frameRate(100);
  fullScreen(P2D);
  //size(1080, 1080, P2D);

  inputSound = new AudioIn(this, 0);
  inputSound.start();

  fft = new FFT(this, nBands);
  fft.input(inputSound);
  soundAmplitude = new Amplitude(this);
  soundAmplitude.input(inputSound);

  exportCanvas = createGraphics(imageExportResolution, imageExportResolution, P2D);
  exportCanvas.beginDraw(); //needed because bug - first export is empty
  exportCanvas.endDraw();

  variablesManager = new VariablesManager(7);
  individualScreen = new IndividualScreen();
  settingsScreen = new SettingsScreen();
}

void draw() {
  if (frameCount ==1) {
    //crashes if done in setup due to taking too long
    //fft = new FFT(this, nBands);
    //soundFiles = loadSongs();
    //changeSong();
    //muteSong();

    String[] cameras = Capture.list();
    print(cameras.length);
    println(cameras);
    if (cameras.length == 0) { //camera is crashing - quick "fix" to use example image
      inputImage = loadImage("exampleImage.jpg");
    } else if (cameras.length == 1) {
      cam = new Capture(this, 1280, 720);
      cam.start();
      setInputImage();
    } else if (cameras.length == 10) {
      cam = new Capture(this, cameras[1]);
      cam.start();
      setInputImage();
    }

    return;
  }

  setInputImage();

  if (!showingSettings) {
    individualScreen.show();
    noCursor();
  } else {
    settingsScreen.show();
    cursor(ARROW);
  }
}

void keyPressed() {
  //if (key == 'm' || key == 'M') changeSong();
  //if (key == 'a' || key == 'A') muteSong();
  if (key == 'e' || key == 'E') individualScreen.exportIndividual();
  if (key == ' ') externalEnabled = !externalEnabled;

  if (keyCode == RIGHT) individualScreen.startTransition(true);
  if (keyCode == LEFT) individualScreen.startTransition(false);

  if (key == TAB) showingSettings = !showingSettings;
}
