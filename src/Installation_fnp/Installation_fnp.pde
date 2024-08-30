//data
//Average Distance from fnp
//Average Position from left to right
//Right most person
//Left most person

import java.util.*;
import processing.video.*;

FnpDataReader reader;
ArrayList<Body> bodies = new ArrayList<Body>();
int maxBodies = 0;
PImage frame = null;
int frameWidth = 960, frameHeight = 413;

PGraphics showCanvas;

PImage qrCode;
PFont light, medium;
String infoText = "The installation shifts every 10 minutes between voting and displaying the top-voted result. Time left is shown by the bar at the bottom.\n\nTo vote, stand in front of the outputs you prefer.\n\nYou can also interact with certain outputs by moving around.\n\n\n\nScan the QR code to access the repository:";

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

int maxTreeDepth = 15;

Operation[] enabledOperations;
String[] fragTemplateShaderLines;
int shaderChangeLineStart; //3 lines need changing (r,g,b), first line is this (as shown in vscode)

VariablesManager variablesManager;

float[] scales = new float[nMonitors];
float minScale = 0.9;
float maxScale = 0.98;
float easing = 0.03;

void settings() {
  fnpSize(2560, 512, P2D);
  //fnpSize(5247, 519, P2D);
  //fnpSize(1749, 900, P2D);

  //fnpFullScreen(P2D);
}

void setup() {
  frameRate(60);
  background(30);
  strokeCap(SQUARE);

  reader = new FnpDataReader("camtop_image_roi_grayscale_full", "camtop_presences");

  showCanvas = createGraphics(1, 1, P2D);

  qrCode = loadImage("qr_code_white.png");
  light = createFont("light.ttf", 128);
  medium = createFont("medium.ttf", 128);

  fragTemplateShaderLines = loadStrings("fragShaderTemplate.glsl");

  shaderChangeLineStart = findLineToChangeInShader(fragTemplateShaderLines)+1;

  columns = setupColumns(nMonitors);
  enabledOperations = setupOperations();
  variablesManager = new VariablesManager(4);

  for (int i = 0; i < scales.length; i++) {
    scales[i] = minScale;
  }
}

void draw() {

  if (frameCount == 1) {
    population = new Population();
    population.initialize();
    return;
  }

  background(30);

  int currentMinutes = minute();
  int currentSeconds = second();

  if (currentMinutes % 10 == 0 && lastChangeMinutes != currentMinutes) {
    //isSelecting =! isSelecting;
    lastChangeMinutes = currentMinutes;

    exportShader(population.getBestIndividual());
    exportImage(population.getBestIndividual());
    population.evolve();
  }

  int totalSecondsPassed = (currentMinutes % 10) * 60 + currentSeconds;
  int totalIntervalSeconds = 10 * 60;
  int secondsLeft = totalIntervalSeconds - totalSecondsPassed;

  float timeLeftRatio = secondsLeft / (float)totalIntervalSeconds;

  if (isSelecting) { //or if program running for less than 30 seconds
    isSelecting = true;
    doSelection();
  } else {
    if (wasSelecting) {
      exportShader(population.getBestIndividual());
      exportImage(population.getBestIndividual());
      population.evolve();

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
  textSize(12);

  fill(255);
  textAlign(LEFT, CENTER);
  text(infoText, columns[0].x + columns[0].z/2, height/2 - qrCodeSize, columns[0].z*0.9, (height - border * 2) * 0.8);

  imageMode(CORNER);

  image(qrCode, columns[0].x + columns[0].z/2 - qrCodeSize, (height - border * 2) * minScale / 2 + height/2 - qrCodeSize, qrCodeSize, qrCodeSize);

  imageMode(CENTER);

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

    PImage currentIndividual = getPhenotype(floor(columns[i].z), floor(imageH/2), population.getIndividual(i).getShader());
    image(currentIndividual, columns[i+1].x + columns[i+1].z * 0.5, border + imageH * 0.5, columns[i].z * scales[i], imageH * scales[i]);

    /*PShader currentShader = population.getIndividual(i).getShader();
     currentShader.set("nVariables", variablesManager.nVariables);
     currentShader.set("variables", variablesManager.getShaderReadyVariables());
     
     noStroke();
     shader(currentShader);
     fill(255);
     //rect(columns[i].x , border, columns[i].z * scales[i], imageH * scales[i]);
     rect(columns[i+1].x + columns[i+1].z * 0.5, border + imageH * 0.5, columns[i].z * scales[i], imageH * scales[i]);
     resetShader();
     
     if (debugging) text(nf(population.getIndividual(i).fitness, 0, 3), columns[i].x, border/2);
     */
  }
}

void doBest() {
  imageMode(CORNER);

  PImage currentIndividual = getPhenotype(width/2, height/2, population.getIndividual(0).getShader());
  image(currentIndividual, 0, 0, width, height);


  /*fill(255);
   noStroke();
   PShader currentShader = population.getIndividual(0).getShader();
   currentShader.set("nVariables", variablesManager.nVariables);
   currentShader.set("variables", variablesManager.getShaderReadyVariables());
   currentShader.set("image", inputImage);
   
   shader(currentShader);
   rect(0, 0, width, height);
   resetShader();*/
}

int[] getVotes() {

  int[] toReturn = new int[populationSize];

  PImage newFrame = reader.getValueAsPImage("camtop_image_roi_grayscale_full");
  JSONObject presencesData = reader.getValueAsJSON("camtop_presences");

  if (newFrame != null) {
    frame = newFrame;
  }
  if (frame != null) {
    if (presencesData != null) {
      for (Body b : bodies) {
        b.alive = false;
      }
      JSONArray presences = presencesData.getJSONArray("presences");
      for (int i = 0; i < presences.size(); i++) {
        JSONObject p = presences.getJSONObject(i);
        String pId = p.getString("id");
        JSONObject centroid = p.getJSONObject("centroid");
        //float cX = centroid.getFloat("x") * frame.width;

        //calculus to avoid perspective distortion
        float diffToCenterX = centroid.getFloat("x") - 0.5;
        float changedDiff = diffToCenterX * 0.55;
        float cX = (centroid.getFloat("x") + changedDiff) * frame.width;

        float cY = centroid.getFloat("y") * frame.height;
        JSONObject bounds = p.getJSONObject("bounds");
        float bX = bounds.getFloat("x") * frame.width;
        float bY = bounds.getFloat("y") * frame.height;
        float bW = bounds.getFloat("w") * frame.width;
        float bH = bounds.getFloat("h") * frame.height;
        boolean existingId = false;
        for (Body b : bodies) {
          if (b.id.equals(pId)) {
            existingId = true;
            b.alive = true;
            b.update(cX, cY, bX, bY, bW, bH);
            break;
          }
        }
        if (!existingId) {
          Body newBody = new Body(pId);
          newBody.update(cX, cY, bX, bY, bW, bH);
          bodies.add(newBody);
        }
      }
      for (int i = bodies.size() - 1; i >= 0; i--) {
        if (!bodies.get(i).alive) {
          bodies.remove(i);
        }
      }
    }
  } else return toReturn;

  if (bodies.size() > maxBodies) maxBodies = bodies.size();

  float w = (frame.width) / (float)populationSize;

  for (int i = 0; i < populationSize; i ++) {
    for (int j = 0; j < bodies.size(); j++) {
      float currentCentroid = frame.width - bodies.get(j).centroidX;
      //if (currentCentroid  w) {
      //  continue;
      //}
      if (currentCentroid > w * (i) && currentCentroid < w * (i+1)) {
        toReturn[i]++;
      }
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

void mouseReleased(){
  //saveFrame();
  population.initialize(); 
 
}
