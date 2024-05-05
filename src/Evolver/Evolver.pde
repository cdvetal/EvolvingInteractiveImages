import java.util.*;
import processing.pdf.*;
import processing.sound.*;
import processing.video.*;


Capture cam;
PImage inputImage;

int maxDepth = 10;
int resolution = 150;
int imageExportResolution = 1920;
int animationExportResolution = 1440;

boolean externalMode;

FFT fft;
SoundFile[] soundFiles;
boolean muted = false;
int nBands = 512;
int soundIndex = 0;

HashMap<String, PShape> icons;
HashMap<String, Integer> colors;
HashMap<String, PFont> fonts;

Run run;

Population population;

int populationSize = 10;
int eliteSize = 2;
int tournamentSize = 3;
float crossoverRate = .3;
float mutationRate = .9;

float aspectRatio = 1; //width = height * aspectRatio
Individual hoveredIndividual = null;

boolean isExportingAnimation;
int nAnimationFrames = 96;

Operation[] operations;
Operation[] enabledOperations;
String[] templateShaderLines;
int shaderChangeLineStart = 157; //3 lines need changing (r,g,b), first line is this (as shown in vscode)

Button pressedButton;

String screen = "mainmenu"; //0 - main menu, 1 - load, 2 - population, 3 - individual

int border = 42; //border around screen
int gap = 24; //gap between columns/items

PVector[] columns; // [(startX, endX, columnWidth), ...]

VariablesManager variablesManager;

MainMenu mainMenu;
LoadMenu loadMenu;
SetupScreen setupScreen;
LeftTab leftTab;
PopulationScreen populationScreen;
IndividualScreen individualScreen;

void setup() {
  size(1920, 1080, P2D);
  //fullScreen(P2D);
  colorMode(RGB, 1);

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
  templateShaderLines = loadStrings("shaderTemplate.glsl");

  run = new Run();
  run.startRun();

  //variablesManager = new VariablesManager(5);

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

  if (key == 'E' || key == 'e') {
    externalMode = !externalMode;
  }

  if (key == 'A' || key == 'a') {
    muteSong();
  }

  if (key == 'M' || key == 'm') {
    changeSong();
  }

  if (hoveredIndividual == null) return;

  if (key == 'S' || key == 's') {
    //exportShader(hoveredIndividual);
    //exportImage(hoveredIndividual);
  }
}

void mouseReleased() {
  if (pressedButton == null) return;
  pressedButton.selected();
  pressedButton = null;
}
