import java.util.*;
import processing.sound.*;
import processing.video.*;

Capture cam;
PImage inputImage;

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
    fft = new FFT(this, nBands);
    soundFiles = loadSongs();
    changeSong();
    muteSong();

    String[] cameras = Capture.list();
    if (cameras.length >= 0) { //camera is crashing - quick "fix" to use example image
      inputImage = loadImage("exampleImage.jpg");
    } else {
      cam = new Capture(this, 1280, 720);
      cam.start();
    }
  }
  
   if(!showingSettings){
     individualScreen.show();
     noCursor();
   }
   else {
     settingsScreen.show();
     cursor(ARROW);
   }
  
  /*
  float external = getExternalValue();
  float[] audioSpectrum = getAudioSpectrum();
  if(externalEnabled) individuals[individualIndex].shader.set("externalVal", external);
  individuals[individualIndex].shader.set("audioSpectrum", audioSpectrum);
  */
}

void keyPressed() {
  if (key == 'm' || key == 'M') changeSong();
  if (key == 'a' || key == 'A') muteSong();
  if (key == 'e' || key == 'E') individualScreen.exportIndividual();
  if (key == ' ') externalEnabled = !externalEnabled;

  if (keyCode == RIGHT) individualScreen.startTransition(true);
  if (keyCode == LEFT) individualScreen.startTransition(false);

  if (key == TAB) showingSettings = !showingSettings;
}


/*
void exportImage(){
  String fileName = individuals[individualIndex].file + millis() + ".png";
  
  String outputPath = sketchPath("outputs/" + individuals[individualIndex].file + "/");
  
  PImage image = individuals[individualIndex].getPhenotype(2100, 1920, getExternalValue(), getAudioSpectrum(), getInputImage());
  image.save(outputPath + fileName);
  
  println("exported image to:" + outputPath);
}*/
