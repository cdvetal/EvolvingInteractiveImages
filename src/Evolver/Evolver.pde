import java.util.*;
import processing.pdf.*;
import processing.sound.*;
import processing.video.*;

//Camera
Capture cam;
PImage inputImage;

//Export
int imageExportResolution = 1920;
PGraphics exportCanvas;
boolean isExportingAnimation;
int nAnimationFrames = 96;

//Sound
FFT fft;
SoundFile[] soundFiles;
boolean muted = false;
int nBands = 512;
int soundIndex = 0;

//assets
HashMap<String, PShape> icons;
HashMap<String, Integer> colors;
HashMap<String, PFont> fonts;

//GUI
String screen = "mainmenu"; //0 - main menu, 1 - load, 2 - population, 3 - individual
int border = 42; //border around screen
int gap = 24; //gap between columns/items
PVector[] columns; // [(startX, endX, columnWidth), ...]
Button pressedButton;
float aspectRatio = 1; //width = height * aspectRatio
Individual hoveredIndividual = null;

MainMenu mainMenu;
LoadMenu loadMenu;
SetupScreen setupScreen;
LeftTab leftTab;
PopulationScreen populationScreen;
IndividualScreen individualScreen;

//GP
Run run;
Population population;

int maxDepth = 15;
int populationSize = 10;
int eliteSize = 2;
int tournamentSize = 3;
float crossoverRate = .3;
float mutationRate = .9;

Operation[] operations;
Operation[] enabledOperations;

//Shaders
String[] fragShaderTemplateLines;
int shaderChangeLineStart = 157; //3 lines need changing (r,g,b), first line is this (as shown in vscode)
VariablesManager variablesManager;

void setup() {
  //size(1920, 1080, P2D);
  fullScreen(P2D);
  colorMode(RGB, 1);
  
  exportCanvas = createGraphics(imageExportResolution, imageExportResolution, P2D);
  exportCanvas.beginDraw(); //needed because bug - first export is empty
  exportCanvas.endDraw();

  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    inputImage = loadImage("shells.jpg");
  } else {
    cam = new Capture(this, 1280, 720);
    cam.start();
  }

  fft = new FFT(this, nBands);
  soundFiles = loadSongs();
  changeSong();

  icons = loadIcons();
  colors = loadColors();
  fonts = loadFonts();
  columns = setupColumns(10);

  operations = setupOperations();
  fragShaderTemplateLines = loadStrings("fragShaderTemplate.glsl");
  shaderChangeLineStart = calculateLineToChangeInShader(fragShaderTemplateLines);

  run = new Run();
  run.startRun();

  mainMenu = new MainMenu();
  loadMenu = new LoadMenu();
  setupScreen = new SetupScreen();
  
  individualScreen = new IndividualScreen();
}

void draw() {
  resetShader();
  background(colors.get("background"));

  switch(screen) {
    case("mainmenu"):
    mainMenu.run();
    break;

    case("loadmenu"):
    loadMenu.run();
    break;

    case("setup"):
    setupScreen.show();
    break;

    case("population"):
    populationScreen.show();
    leftTab.show();
    break;

    case("individual"):
    individualScreen.show();
    leftTab.show();

    break;
  }
}

void setInputImage() {
  if (cam == null) return;
  if (cam.available() != true) return;

  cam.read();
  inputImage = cam;
}

float[] getAudioSpectrum() {
  float[] spectrum = new float[nBands];
  fft.analyze(spectrum);
  return spectrum;
}

void mousePressed() {
  if (isExportingAnimation) return;

  if (hoveredIndividual == null) return;
  if (mouseButton == LEFT) hoveredIndividual.giveFitness();
  if (mouseButton == RIGHT) hoveredIndividual.setFitness(0);
}

void keyPressed() {
  /*if (key==27) {
   key=0;
   }*/

  if (isExportingAnimation) return;

  if (key == ' ') {
    population.evolve();
  }
}

void mouseReleased() {
  if (pressedButton == null) return;
  pressedButton.selected();
  pressedButton = null;
}
