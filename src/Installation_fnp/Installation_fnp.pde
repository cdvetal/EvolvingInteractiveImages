import java.util.*;
import gab.opencv.*;
import processing.video.*;
import java.awt.Rectangle;

boolean debugging = false;

Capture cam;
OpenCV openCV;
PImage inputImage;

//boundaries to avoid detection on either side of camera feed, fine tune
int detectionBoundary = 100;

int nMonitors = 9;
int selectionMinutes = 10;
boolean isSelecting = false;
int imageExportResolution = 1920;

int gap = 24, border = 42;
PVector[] columns;

Population population;

int populationSize = nMonitors;
int eliteSize = 1;
float crossoverRate = 0.3;
float mutationRate = 0.3;
int tournamentSize = 2;

int maxDepth = 8;

Operation[] enabledOperations;
String[] fragTemplateShaderLines;
int shaderChangeLineStart = 157; //3 lines need changing (r,g,b), first line is this (as shown in vscode)

VariablesManager variablesManager;

void settings() {
  //fnpSize(1749, 346, P2D);
  fnpSize(1749, 900, P2D);

  //fnpFullScreen(P2D);
}

void setup() {
  frameRate(60);
  background(0);
  strokeCap(SQUARE);

  cam = new Capture(this, 1280, 720);
  //openCV = new OpenCV(this, 1280, 720);
  //cam.start();

  fragTemplateShaderLines = loadStrings("fragShaderTemplate.glsl");

  columns = setupColumns(nMonitors);
  enabledOperations = setupOperations();
  variablesManager = new VariablesManager(3);

  population = new Population();
  population.initialize();
}

void draw() {
  if (frameCount == 1) {
    openCV = new OpenCV(this, 1280, 720);
    //haar cascade from https://github.com/opencv/opencv/tree/master/data/haarcascades
    openCV.loadCascade("haarcascade_profileface.xml");
    cam.start();
  }

  background(0);
  cam.read();
  inputImage = cam;

  int currentMinutes = minute();

  float timeLeftRatio;

  if (currentMinutes < selectionMinutes || millis() < 10000) { //or if program running for less than 30 seconds
    isSelecting = true;
    doSelection();
    int timeLeft = selectionMinutes - minute();
    timeLeftRatio = timeLeft / selectionMinutes * 1.0;
    openCV.loadImage(inputImage);
  } else {
    if (isSelecting) {
      population.evolve();
      //exportImage(population.getIndividual(0));
      isSelecting = false;
    }
    doBest();
    int timeLeft = 60 - minute();
    timeLeftRatio = timeLeft / (60.0 - selectionMinutes);
  }

  drawTimeLine(timeLeftRatio);
}

void doSelection() {
  int[] votes = getVotes();
  
  int imageH = - border * 2 + height;
  for (int i = 0; i < populationSize; i ++) {
    if (votes[populationSize - i - 1] > 0) { //flipping here easier than reversing image
      noFill();
      stroke(255);
      strokeWeight(8);
      rect(columns[i].x, border, columns[i].z, imageH);
      for (int j = 0; j < votes[i]; j++) {
        population.getIndividual(i).giveFitness();
      }
    }

    PShader currentShader = population.getIndividual(i).getShader();
    currentShader.set("nVariables", variablesManager.nVariables);
    currentShader.set("variables", variablesManager.getShaderReadyVariables());
    currentShader.set("image", inputImage);

    noStroke();
    shader(currentShader);
    fill(255);
    rect(columns[i].x, border, columns[i].z, imageH);
    resetShader();
    
    if(debugging) text(nf(population.getIndividual(i).fitness, 0, 3), columns[i].x, border/2);
  }
  
  if(!debugging) return;
  openCV.loadImage(inputImage);
  Rectangle[] detections = openCV.detect();
  image(inputImage, 0, 0);
  for (int i = 0; i < detections.length; i++) {
    noFill();
    stroke(255);
    strokeWeight(10);
    rect(detections[i].x, detections[i].y, detections[i].width, detections[i].height);
  }
  line(detectionBoundary, 0, detectionBoundary, inputImage.height);
  line(inputImage.width - detectionBoundary, 0, inputImage.width - detectionBoundary, inputImage.height);
}

void doBest() {
  fill(255);
  PShader currentShader = population.getIndividual(0).getShader();
  currentShader.set("nVariables", variablesManager.nVariables);
  currentShader.set("variables", variablesManager.getShaderReadyVariables());
  currentShader.set("image", inputImage);

  shader(currentShader);
  rect(0, 0, width, height);
  resetShader();
}

int[] getVotes() {
  openCV.loadImage(inputImage);
  Rectangle[] detections = openCV.detect();
  PVector[] bodyCenters = rectangleToCenters(detections);

  int[] toReturn = new int[populationSize];

  float w = (inputImage.width - detectionBoundary*2) / populationSize;

  for (int i = 0; i < populationSize; i ++) {
    for (int j = 0; j < bodyCenters.length; j++) {
      if (bodyCenters[j].x < detectionBoundary || bodyCenters[j].x > inputImage.width - detectionBoundary) {
        continue;
      }
      if (bodyCenters[j].x > w * i && bodyCenters[j].x < w * (i + 1)) {
        toReturn[i]++;
      }
    }

    if (mouseX > w * i && mouseX < w * (i + 1)) {
      toReturn[i]++;
    }
  }

  return toReturn;
}

void drawTimeLine(float ratio) {
  strokeWeight(gap);
  stroke(0);
  line(0, height, width, height);
  stroke(255);
  line(0, height, ratio * width, height);
}
