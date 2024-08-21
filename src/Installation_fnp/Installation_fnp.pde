//data
//Average Distance from fnp
//Average Position from left to right
//Right most person
//Left most person

import java.util.*;
import gab.opencv.*;
import processing.video.*;
import java.awt.Rectangle;

boolean debugging = false;

Capture cam;
OpenCV openCV;
PImage inputImage;

PImage qrCode;
PFont light, medium;
String infoText = "The installation shifts every 10 minutes between voting and displaying the top-voted result.\n\nTo vote, stand in front of the outputs you prefer.\n\nYou can also interact with certain outputs by moving around.";

//boundaries to avoid detection on either side of camera feed, fine tune
int detectionBoundary = 100;

int nMonitors = 9;
int lastChangeMinutes;
int selectionMinutes = 10;
boolean isSelecting = true;
boolean wasSelecting = true;
int imageExportResolution = 1920;

int gap = 24, border = 42;
PVector[] columns;

Population population;

int populationSize = nMonitors - 1;
int eliteSize = 1;
float crossoverRate = 0.4;
float mutationRate = 0.5;
int tournamentSize = 2;

int maxTreeDepth = 3;

Operation[] enabledOperations;
String[] fragTemplateShaderLines;
int shaderChangeLineStart; //3 lines need changing (r,g,b), first line is this (as shown in vscode)

VariablesManager variablesManager;

float[] scales = new float[nMonitors];
float minScale = 0.95;
float maxScale = 1;
float easing = 0.05;

void settings() {
  fnpSize(1749, 346, P2D);
  //fnpSize(1749, 900, P2D);

  //fnpFullScreen(P2D);
}

void setup() {
  frameRate(60);
  background(0);
  strokeCap(SQUARE);

  cam = new Capture(this, 1280, 720);

  qrCode = loadImage("qr_code_white.png");
  light = createFont("light.ttf", 128);
  medium = createFont("medium.ttf", 128);

  fragTemplateShaderLines = loadStrings("fragShaderTemplate.glsl");

  shaderChangeLineStart = findLineToChangeInShader(fragTemplateShaderLines)+1;

  columns = setupColumns(nMonitors);
  enabledOperations = setupOperations();
  variablesManager = new VariablesManager(3);

  population = new Population();
  population.initialize();

  for (int i = 0; i < scales.length; i++) {
    scales[i] = minScale;
  }
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
  int currentSeconds = second();

  if (currentMinutes % 10 == 0 && lastChangeMinutes != currentMinutes) {
    isSelecting =! isSelecting;
    lastChangeMinutes = currentMinutes;
  }

  int totalSecondsPassed = (currentMinutes % 10) * 60 + currentSeconds;
  int totalIntervalSeconds = 10 * 60;
  int secondsLeft = totalIntervalSeconds - totalSecondsPassed;

  float timeLeftRatio = secondsLeft / (float)totalIntervalSeconds;

  if (isSelecting) { //or if program running for less than 30 seconds
    isSelecting = true;
    doSelection();
    openCV.loadImage(inputImage);
  } else {
    if (wasSelecting) {
      population.evolve();
      exportShader(population.getIndividual(0));
      exportImage(population.getIndividual(0));
      wasSelecting = false;
    }
    doBest();
  }

  drawTimeLine(timeLeftRatio);
}

void doSelection() {
  int[] votes = reverse(getVotes()); //flipping because image is mirrored

  int imageH = - border * 2 + height;

  int highestVotes = 0;

  for (int i = 0; i < votes.length; i++) {
    if (votes[i] > highestVotes) highestVotes = votes[i];
  }

  float qrCodeSize = columns[0].z/5;

  textFont(light);
  textSize(10);

  fill(255);
  textAlign(LEFT, CENTER);
  text(infoText, columns[0].x + columns[0].z/2, height/2 - qrCodeSize, columns[0].z*0.9, (height - border * 2) * 0.8);


  image(qrCode, columns[0].x + columns[0].z/2 - qrCodeSize, (height - border * 2) * minScale / 2 + height/2 - qrCodeSize, qrCodeSize, qrCodeSize);

  rectMode(CENTER);

  for (int i = 0; i < populationSize; i ++) {
    float targetScale = minScale;

    if (votes[i] > 0) {
      if (scales[i] > minScale + (maxScale - minScale) * 0.9) {
        for (int j = 0; j < votes[i]; j++) {
          population.getIndividual(i).giveFitness();
        }
      }
      targetScale = maxScale;
    }

    float scaleDiff = targetScale - scales[i];
    scales[i] += scaleDiff * easing;

    PShader currentShader = population.getIndividual(i).getShader();
    currentShader.set("nVariables", variablesManager.nVariables);
    currentShader.set("variables", variablesManager.getShaderReadyVariables());
    currentShader.set("image", inputImage);

    noStroke();
    shader(currentShader);
    fill(255);
    //rect(columns[i].x , border, columns[i].z * scales[i], imageH * scales[i]);
    rect(columns[i+1].x + columns[i+1].z * 0.5, border + imageH * 0.5, columns[i].z * scales[i], imageH * scales[i]);
    resetShader();

    if (debugging) text(nf(population.getIndividual(i).fitness, 0, 3), columns[i].x, border/2);
  }

  if (!debugging) return;
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
  rectMode(CORNER);

  fill(255);
  noStroke();
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
  rectMode(CENTER);

  strokeWeight(2);
  stroke(0);
  fill(255);
  //rect(-10, height - 16, ratio * width + 10, 8);
  rect(width/2, height - 16, ratio * width + 10, 8);
}
